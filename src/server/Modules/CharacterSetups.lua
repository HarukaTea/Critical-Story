--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AttackUtil = require(SSS.Modules.Utils.AttackUtil)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(SSS.Modules.Data.ServerEvents)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)

local AttributeChange = Fusion.AttributeChange

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local wait, delay = task.wait, task.delay
local floor, random = math.floor, math.random
local cfNew = CFrame.new
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB

--[[
    Actions when character spawns, apply attributes for UIs to use
]]
function CharacterSetups:Setup()
    local char, plr = self.char, self.plr

    repeat wait() until plr:GetAttribute("PlayerDataLoaded")

    local function _createFolder(name: string, parent: Folder) : Folder
        local folder = instanceNew("Folder")
        folder.Name = name
        folder.Parent = parent

        return folder
    end
    local function _createStats()
        local charStats = _createFolder("CharStats", char)

        for i, v in self.ATTRIBUTES do
            char:SetAttribute(i, v)
        end
        local objValue = instanceNew("ObjectValue")
        objValue.Name = "TargetMonster"
        objValue.Parent = charStats

        _createFolder("Items", charStats)
        _createFolder("ExtraOrbs", charStats)
        _createFolder("TargetMonsters", charStats)
        _createFolder("EffectsList", charStats)

        return charStats
    end
    self.charStats = _createStats()
    self.humanoid.BreakJointsOnDeath = false
    char:SetAttribute("HitCD", 0)

    self.timeCalStop = Clock(1, function()
		HarukaLib:Add(plr, "PlayTime", 1)
	end)
    self.hitCDStop = Clock(1, function()
        HarukaLib:Add(char, "HitCD", -1)
    end)

    ServerUtil:EquipWeapon(char)

    if plr:GetAttribute("PlayerSpawnPos") ~= Vector3.zero then
		char:WaitForChild("HumanoidRootPart", 999)

		char:PivotTo(cfNew(plr:GetAttribute("PlayerSpawnPos")))
	end
end

--[[
    Clear actions when character is dead or fall into eternal void
]]
function CharacterSetups:Clear(char: Model)
    char:SetAttribute("InCombat", false)

	for _, monster in self.charStats.TargetMonsters:GetChildren() do
		monster.Value.TargetingList[char.Name]:Destroy()
	end
    for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
        if orbFolder.Name == char.Name then wait() orbFolder:Destroy() end
    end

	self.timeCalStop()
    self.hitCDStop()

	ServerUtil:RagdollNPC(char)
end

--[[
    Repair the shield, can be cancelled at any time
]]
function CharacterSetups:RepairShield()
    RepS.Resources.Unloads.RepairShield:Clone().Parent = self.char
end

--[[
    Heals the player, can be cancelled at any time
]]
function CharacterSetups:Heal()
    RepS.Resources.Unloads.HealHP:Clone().Parent = self.char
end

--[[
    Check the shield everytime they changed, repair it if needed
]]
function CharacterSetups:ShieldCheck()
    local char, isBroken = self.char, self.isBroken
    local shield, maxShield = char:GetAttribute("Shield"), char:GetAttribute("MaxShield")

	if shield < 0 then char:SetAttribute("Shield", 0) end
	if shield >= maxShield then
		char:SetAttribute("Shield", maxShield)

		isBroken = false
		return
	end
	if shield == 0 and not isBroken then
		isBroken = true

		Events.PlaySound:Fire(self.plr, workspace.Sounds.SFXs.ShieldBroken)
	end
end

--[[
    Cancel the heal or repair threads cuz player is unsafe rn
]]
function CharacterSetups:CancelHealing()
    local char = self.char

    if char:GetAttribute("HitCD") < 0 then char:SetAttribute("HitCD", 1) end
    HarukaLib:Add(char, "HitCD", 15)
    if char:GetAttribute("HitCD") > 15 then char:SetAttribute("HitCD", 15) end

    if char:FindFirstChild("HealHP") then char.HealHP:Destroy() end
    if char:FindFirstChild("RepairShield") then char.RepairShield:Destroy() end
    char:SetAttribute("Repairing", false)
    char:SetAttribute("Healing", false)

    self:RepairShield()
    self:Heal()
end

--[[
    The actions after character is actually hit by attacks
]]
function CharacterSetups:CharTakeDMG(plr: Player, monster: Model, dmgType: boolean?)
	if not monster then return end

	local char = plr.Character
	local humanoid = char.Humanoid
	local shield = char:GetAttribute("Shield")
	local dmg, finalDmg = monster:GetAttribute("Damage"), monster:GetAttribute("Damage")

	if monster == "Abyss" then
		char.Humanoid:TakeDamage(char.Humanoid.MaxHealth + 1)
		return
	end

    self:CancelHealing()

	--- Knight class skills
	if char:GetAttribute("Guard") > 0 then
		finalDmg = floor(dmg - (dmg * char:GetAttribute("Guard")) / 100)
		char:SetAttribute("Guard", 0)
	end

	--- shield
	if shield > 0 then
		if dmgType == true then -- "Pierce"
			humanoid:TakeDamage(finalDmg)
			ServerUtil:ShowNumber(char, finalDmg)
			return
		end

		if finalDmg > shield then
			humanoid:TakeDamage(floor(finalDmg - shield))
			ServerUtil:ShowNumber(char, finalDmg - shield)

			char:SetAttribute("Shield", 0)
			return
		end

		char:SetAttribute("Shield", shield - finalDmg)
		ServerUtil:ShowNumber(char, finalDmg, fromRGB(122, 122, 122))
		return
	end

	humanoid:TakeDamage(finalDmg)
	ServerUtil:ShowNumber(char, finalDmg)
end

--[[
    Character hit monsters' attacks
]]
function CharacterSetups:OnHit(hit: BasePart)
    if hit.Parent:GetAttribute("IsOrb") then
		local orb, char = hit.Parent :: Model, self.char :: Model
        local plr = Players:GetPlayerFromCharacter(char)
		local HRP = char.PrimaryPart

		--- pre checks
		if self.orbTouchCD then return end
        if not orb:FindFirstChild("Owner") then return end
        if orb.Owner.Value ~= char then return end
        if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
        if not char.CharStats.TargetMonster.Value then return end
        if not HRP then return end
        if not orb.Parent then return end
        if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then return end

		self.orbTouchCD = true
        delay(0.2, function()
            self.orbTouchCD = false
        end)

        local monster = char.CharStats.TargetMonster.Value
        local baseDamage = char:GetAttribute("Damage")

        orb.Owner:Destroy()

        --- final check
        if not monster.PrimaryPart then return end

        local subStyle = orb:GetAttribute("SubStyle")
        local style = if subStyle then subStyle else orb:GetAttribute("Style")
        if AttackUtil[style] then
            AttackUtil[style](plr, monster, baseDamage, orb)
        end

        orb:Destroy()

    elseif hit.Parent:GetAttribute("IsDamage") then
		local damagePart, char = hit.Parent :: Model, self.char :: Model

		--- checks
		if self.dmgTouchCD then return end
		if not damagePart:FindFirstChild("Owner") then return end
		if not char.PrimaryPart then return end

		self.dmgTouchCD = true
		delay(0.55, function()
            self.dmgTouchCD = false
        end)

        self:CharTakeDMG(self.plr, damagePart.Owner.Value, damagePart:GetAttribute("Pierce"))
	end
end

--[[
    Spawn orbs automatically when character is in combat
]]
function CharacterSetups:OrbSpawnHandler()
    local char, orbFolders = self.char, workspace.MapComponents.OrbFolders
    local monster, orbAttack = char.CharStats.TargetMonster, RepS.Package.PlayerAttacks

    local function _placeOrb(orb: Model, pos: CFrame, lifeTime: number)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, lifeTime)
    end
    local function _spawnOrb(isSpawned: boolean?)
        local isInCombat, class, lifeTime =
            char:GetAttribute("InCombat"), self.plr:GetAttribute("Class"), char:GetAttribute("OrbLifeTime")

        if monster.Value and isInCombat and orbFolders:FindFirstChild(char.Name) and char.Humanoid.Health > 0 then
            local orb
            if class == "Alchemist" then
                orb = orbAttack["AlchemistOrb" .. random(1, 3)]:Clone() :: Model
            else
                orb = orbAttack[class .. "Orb"]:Clone() :: Model
            end
            _placeOrb(orb, ServerUtil:GenerateOrbPos(monster.Value), lifeTime)

            --- extra orbs from items
            if not isSpawned then
                for _, exOrb in char.CharStats.ExtraOrbs:GetChildren() do
                    _placeOrb(orbAttack[exOrb.Value]:Clone(), ServerUtil:GenerateOrbPos(monster.Value), lifeTime)
                end
            end
        end
    end

    if char:GetAttribute("InCombat") then
		if char:GetAttribute("SpawnMultiOrb") then
			for i = 1, 3 do _spawnOrb(true) end
		end

		self.stopSpawn = Clock(3, function()
			if char:GetAttribute("InCombat") then _spawnOrb() end
		end)
	else
		if self.stopSpawn then self.stopSpawn() end

		self.stopSpawn = nil
	end
end

--[[
    Handle the class-related attributes
]]
function CharacterSetups:ClassAttributesHandler()
    local char = self.char

    --- warrior
    char.Humanoid.StateChanged:Connect(function(state)
        if state == Enum.HumanoidStateType.Landed
            or state ~= Enum.HumanoidStateType.Jumping
            or state ~= Enum.HumanoidStateType.Freefall
        then
            self.char:SetAttribute("Combo", 0)
        end
    end)

    --- wizard
    char:GetAttributeChangedSignal("InCombat"):Connect(function()
        if not char:GetAttribute("InCombat") then
            char:SetAttribute("WizardCasted", 0)
            char:SetAttribute("Guard", 0)
            char:SetAttribute("RogueCritical", 0)
        end
    end)

    --- knight
    Clock(1.1, function()
        HarukaLib:Add(char, "Guard", -1)

        if char:GetAttribute("Guard") < 0 then
            char:SetAttribute("Guard", 0)
        end
    end)

    --- rogue
    Clock(0.7, function()
        HarukaLib:Add(char, "RogueCritical", -1)

        if char:GetAttribute("RogueCritical") < 0 then
            char:SetAttribute("RogueCritical", 0)
        end
    end)
end

return function (char: Model)
    local self = setmetatable({}, CharacterSetups)

    self.char = char
    self.plr = Players:GetPlayerFromCharacter(char)
    self.humanoid = char:WaitForChild("Humanoid") :: Humanoid
    self.charStats = nil
    self.timeCalStop, self.hitCDStop = nil, nil
    self.isBroken, self.isDamaged = false, false
    self.repairing, self.healing = nil, nil
    self.stopSpawn = nil
    self.lvUpCD, self.dmgTouchCD, self.orbTouchCD = false, false, false

    self.ATTRIBUTES = {
		CriChance = 1,
		InCombat = false,
		Magic = 20,
		Mana = 100,
		Damage = 15,
		MaxMana = 100,
		MaxShield = 20,
		OrbLifeTime = 10,
		Shield = 20,
        Repairing = false,
        Healing = false,

		HealthBuff = 0,
		JumpBuff = 0,
		MagicBuff = 0,
		ManaBuff = 0,
		DamageBuff = 0,
		ShieldBuff = 0,
		SpeedBuff = 0,
        RestoreBuff = 15,

        Combo = 0,
        Arrows = 0,
        WizardCasted = 0,
        Guard = 0,
        RogueCritical = 0
	}

    repeat wait() until self.plr:GetAttribute("PlayerDataLoaded")
    self:Setup()

    --// Connections
    self.humanoid.Died:Once(function()
        self:Clear(char)
    end)
    self.humanoid.Touched:Connect(function(hit: BasePart)
        self:OnHit(hit)
    end)

    local plr, humanoid = self.plr, self.humanoid
    local function _manaCheck()
        local mana, maxMana = self.char:GetAttribute("Mana"), self.char:GetAttribute("MaxMana")

        if mana > maxMana then self.char:SetAttribute("Mana", maxMana) end
    end
    local function _updateDMG()
        char:SetAttribute("Damage", floor(plr:GetAttribute("DmgPoints") ^ 1.5) + 15 + char:GetAttribute("DamageBuff"))
    end
    local function _updateMagic()
        char:SetAttribute("Magic", floor(plr:GetAttribute("MagicPoints") ^ 1.42) + 12 + char:GetAttribute("MagicBuff"))
    end
    local function _updateMana()
        char:SetAttribute("MaxMana", floor(plr:GetAttribute("ManaPoints") ^ 1.9) + 60 + char:GetAttribute("ManaBuff"))
        char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
    end
    local function _updateShield()
        char:SetAttribute("MaxShield", floor(plr:GetAttribute("ShieldPoints") ^ 1.4) + 20 + char:GetAttribute("ShieldBuff"))
        char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
    end
    local function _updateHP()
        humanoid.MaxHealth = floor(plr:GetAttribute("HealthPoints") ^ 1.5) + 100 + char:GetAttribute("HealthBuff")
        humanoid.Health = humanoid.MaxHealth
    end
    local function _updateSpeed()
        humanoid.WalkSpeed = 30 + char:GetAttribute("SpeedBuff")
    end
    local function _updateJump()
        humanoid.JumpPower = 50 + char:GetAttribute("JumpBuff")
    end
    local function _levelReqCheck()
        local level = plr:GetAttribute("Levels")

        if plr:GetAttribute("EXP") >= floor(level ^ 1.85) + 60 then
            if self.lvUpCD then return end

            self.lvUpCD = true
            Signals.LevelUp:Fire(plr)

            wait(1)
            self.lvUpCD = false
        end
    end
    _updateDMG()
    _updateMagic()
    _updateMana()
    _updateShield()
    _updateHP()
    _updateSpeed()
    _updateJump()
    _levelReqCheck()
    self:ClassAttributesHandler()

    Fusion.Hydrate(plr)({
        [AttributeChange("DmgPoints")] = _updateDMG,
        [AttributeChange("MagicPoints")] = _updateMagic,
        [AttributeChange("ManaPoints")] = _updateMana,
        [AttributeChange("ShieldPoints")] = _updateShield,
        [AttributeChange("HealthPoints")] = _updateHP,
        [AttributeChange("EXP")] = _levelReqCheck,
        [AttributeChange("Class")] = function()
            ServerUtil:EquipWeapon(char)
        end
    })
    Fusion.Hydrate(char)({
        [AttributeChange("DamageBuff")] = _updateDMG,
        [AttributeChange("MagicBuff")] = _updateMagic,
        [AttributeChange("ManaBuff")] = _updateMana,
        [AttributeChange("Mana")] = _manaCheck,
        [AttributeChange("ShieldBuff")] = _updateShield,
        [AttributeChange("HealthBuff")] = _updateHP,
        [AttributeChange("SpeedBuff")] = _updateSpeed,
        [AttributeChange("JumpBuff")] = _updateJump,
        [AttributeChange("Shield")] = function()
            self:ShieldCheck()
        end,
        [AttributeChange("InCombat")] = function()
            self:OrbSpawnHandler()
        end
    })
end