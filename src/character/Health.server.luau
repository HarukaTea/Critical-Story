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
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local charStats = nil
local isBroken = false
local lvUpCD, dmgTouchCD, orbTouchCD = false, false, false

local ATTRIBUTES = {
    InCombat = false,

    Magic = 0,
    Mana = 0,
    MinDMG = 5,
    MaxDMG = 15,
    MaxMana = 0,
    MaxShield = 0,
    OrbLifeTime = 10,
    Shield = 0,

    Repairing = false,
    Healing = false,
    HitCD = 0,

    HealthBuff = 0,
    JumpBuff = 0,
    MagicBuff = 0,
    ManaBuff = 0,
    MinDMGBuff = 0,
    MaxDMGBuff = 0,
    ShieldBuff = 0,
    SpeedBuff = 0,
    RestoreBuff = 15,
    HealBuff = 10,

    BurnChance = 0,
    DodgeChance = 0,
    CriChance = 1,

    Combo = 0,
    Arrows = 0,
    WizardCasted = 0,
    Guard = 0,
    RogueCritical = 0
}

local AttributeChange = Fusion.AttributeChange

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local wait = task.wait
local floor, random = math.floor, math.random
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB

local function charTakeDMG(monster: Model, dmgType: boolean?)
	if not monster then return end

	local shield = char:GetAttribute("Shield") :: number
	local dmg = monster:GetAttribute("Damage") :: number

    --- if attacker is void
	if monster == "Abyss" then
		char.Humanoid:TakeDamage(char.Humanoid.MaxHealth + 1)
		return
	end

    --- some hit cd detections
    HarukaLib:Add(char, "HitCD", 15)
    if char:GetAttribute("HitCD") > 15 then char:SetAttribute("HitCD", 15) end

    if char:FindFirstChild("HealHP") then char.HealHP:Destroy() end
    if char:FindFirstChild("RepairShield") then char.RepairShield:Destroy() end
    char:SetAttribute("Repairing", false)
    char:SetAttribute("Healing", false)

    if shield < char:GetAttribute("MaxShield") then
        RepS.Resources.Unloads.RepairShield:Clone().Parent = char
    end
    if humanoid.Health < humanoid.MaxHealth then
        RepS.Resources.Unloads.HealHP:Clone().Parent = char
    end

	--- Knight class skills
	if char:GetAttribute("Guard") > 0 then
        local oriDmg = dmg
		dmg = floor(oriDmg - (oriDmg * char:GetAttribute("Guard")) / 100)

		char:SetAttribute("Guard", 0)
	end

	--- shield
	if shield > 0 then
		if dmgType == true then -- "Pierce"
			humanoid:TakeDamage(dmg)
			ServerUtil:ShowNumber(char, dmg)
			return
		end

		if dmg > shield then
			humanoid:TakeDamage(floor(dmg - shield))
			ServerUtil:ShowNumber(char, dmg - shield)

			char:SetAttribute("Shield", 0)
			return
		end

		HarukaLib:Add(char, "Shield", -dmg)
		ServerUtil:ShowNumber(char, dmg, fromRGB(122, 122, 122))
		return
	end

	humanoid:TakeDamage(dmg)
	ServerUtil:ShowNumber(char, dmg)
end

local stopSpawn
local function orbSpawnHandler(state: boolean)
    local orbFolders = workspace.MapComponents.OrbFolders :: Folder
    local monster, orbAttack = char.CharStats.TargetMonster :: ObjectValue, RepS.Package.PlayerAttacks :: Folder

    local function _placeOrb(orb: Model, pos: CFrame, lifeTime: number)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb:SetAttribute("OrbLifeTime", lifeTime)
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, lifeTime)
    end
    local function _spawnOrb(isSpawned: boolean?)
        local isInCombat, class, lifeTime =
            char:GetAttribute("InCombat") :: boolean,
            plr:GetAttribute("Class") :: string,
            char:GetAttribute("OrbLifeTime") :: number

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
                for attr, val in char.CharStats.ExtraOrbs:GetAttributes() do
                    if not val then continue end

                    _placeOrb(orbAttack[attr.Name]:Clone(), ServerUtil:GenerateOrbPos(monster.Value), lifeTime)
                end
            end
        end
    end

    if state then
		if char:GetAttribute("CanSpawnMultiOrb") then
			for _ = 1, 3 do _spawnOrb(true) end
		end

		stopSpawn = Clock(3, function()
			if char:GetAttribute("InCombat") then _spawnOrb() end
		end)
	else
		if stopSpawn then stopSpawn() end

        stopSpawn = nil
	end
end

repeat wait() until plr:GetAttribute("PlayerDataLoaded")
local function setup()
    char.PrimaryPart = char.Humanoid.RootPart

    local function _createFolder(name: string, parent: Folder) : Folder
        local folder = instanceNew("Folder")
        folder.Name = name
        folder.Parent = parent

        return folder
    end
    local function _createStats()
        charStats = _createFolder("CharStats", char)

        for i, v in ATTRIBUTES do
            char:SetAttribute(i, v)
        end
        local objValue = instanceNew("ObjectValue")
        objValue.Name = "TargetMonster"
        objValue.Parent = charStats

        _createFolder("Items", charStats)
        _createFolder("ExtraOrbs", charStats)
        _createFolder("TargetMonsters", charStats)
        _createFolder("EffectsList", charStats)
    end
    _createStats()

    ServerUtil:SetCollisionGroup(char, "Player")

    humanoid.BreakJointsOnDeath = false
    Clock(1, function()
        HarukaLib:Add(plr, "PlayTime", 1)

        if char:GetAttribute("HitCD") >= 0 then HarukaLib:Add(char, "HitCD", -1) end
    end)
end
setup()

local function classAttributesSetup()
    --- warrior
    char.Humanoid.StateChanged:Connect(function(state)
        if state == Enum.HumanoidStateType.Landed
            or state ~= Enum.HumanoidStateType.Jumping
            or state ~= Enum.HumanoidStateType.Freefall
        then
            char:SetAttribute("Combo", 0)
        end
    end)

    --- wizard
    char:GetAttributeChangedSignal("InCombat"):Connect(function()
        if not char:GetAttribute("InCombat") then
            char:SetAttribute("WizardCasted", 0)
            char:SetAttribute("Guard", 0)
            char:SetAttribute("RogueCritical", 0)
            char:SetAttribute("ResearchStage", 0)
        end
    end)

    --- knight
    Clock(1.1, function()
        if char:GetAttribute("Guard") <= 0 then return end

        HarukaLib:Add(char, "Guard", -1)
    end)

    --- rogue
    Clock(0.7, function()
        if char:GetAttribute("RogueCritical") <= 0 then return end

        HarukaLib:Add(char, "RogueCritical", -1)
    end)
end
classAttributesSetup()

--// Connections
local function onDead()
    char:SetAttribute("InCombat", false)

    for _, monster in char.CharStats.TargetMonsters:GetChildren() do
        monster.Value.TargetingList[char.Name]:Destroy()
    end
    for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
        if orbFolder.Name == char.Name then orbFolder:Destroy() end
    end

    ServerUtil:RagdollNPC(char)
end
local function onTouch(hit: BasePart)
    if not hit or not hit.Parent then return end

    if hit.Parent:GetAttribute("IsOrb") then
        local orb = hit.Parent :: Model
        local HRP = char.PrimaryPart

        --- pre checks
        if orbTouchCD then return end
        if not orb:FindFirstChild("Owner") then return end
        if orb.Owner.Value ~= char then return end
        if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
        if not char.CharStats.TargetMonster.Value then return end
        if not HRP then return end
        if not orb.Parent then return end
        if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then return end

        orbTouchCD = true
        char.Humanoid.AutoRotate = false
        Spawn(function()
            wait(0.1)
            orbTouchCD = false
            char.Humanoid.AutoRotate = true
        end)

        local monster = char.CharStats.TargetMonster.Value :: Model
        local minDMG, maxDMG = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
        local baseDamage = if minDMG >= maxDMG then maxDMG else random(minDMG, maxDMG)

        orb.Owner:Destroy()

        --- final check
        if not monster.PrimaryPart then return end
        if monster:GetAttribute("CantAttack") then baseDamage = 0 end

        local subStyle = orb:GetAttribute("SubStyle") :: string?
        local style = if subStyle then subStyle else orb:GetAttribute("Style") :: string
        if AttackUtil[style] then
            AttackUtil[style](plr, monster, baseDamage, orb)
        end

        orb:Destroy()

    elseif hit.Parent:GetAttribute("IsDamage") then
        local damagePart = hit.Parent :: Model

        --- checks
        if dmgTouchCD then return end
        if not damagePart:FindFirstChild("Owner") then return end
        if not char.PrimaryPart then return end
        if not damagePart.Owner.Value then return end
        if not damagePart.Owner.Value.TargetingList:FindFirstChild(char.Name) then return end

        dmgTouchCD = true
        Spawn(function()
            wait(0.55)
            dmgTouchCD = false
        end)

        charTakeDMG(damagePart.Owner.Value, damagePart:GetAttribute("Pierce"))
    end
end
humanoid.Died:Once(onDead)
humanoid.Touched:Connect(onTouch)

local function manaCheck(mana)
    local maxMana = char:GetAttribute("MaxMana")

    if mana > maxMana then char:SetAttribute("Mana", maxMana) end
end
local function updateMinDMG()
    char:SetAttribute("MinDMG", floor(plr:GetAttribute("DmgPoints") ^ 1.5) + 5 + char:GetAttribute("MinDMGBuff"))
end
local function updateMaxDMG()
    char:SetAttribute("MaxDMG", floor(plr:GetAttribute("DmgPoints") ^ 1.5) + 15 + char:GetAttribute("MaxDMGBuff"))
end
local function updateMagic()
    char:SetAttribute("Magic", floor(plr:GetAttribute("MagicPoints") ^ 1.42) + 20 + char:GetAttribute("MagicBuff"))
end
local function updateMana()
    char:SetAttribute("MaxMana", floor(plr:GetAttribute("ManaPoints") ^ 1.9) + 100 + char:GetAttribute("ManaBuff"))
    char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
end
local function updateShield()
    char:SetAttribute("MaxShield", floor(plr:GetAttribute("ShieldPoints") ^ 1.4) + 20 + char:GetAttribute("ShieldBuff"))
    char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
end
local function updateHP()
    humanoid.MaxHealth = floor(plr:GetAttribute("HealthPoints") ^ 1.7) + 100 + char:GetAttribute("HealthBuff")
    humanoid.Health = humanoid.MaxHealth
end
local function updateSpeed(speed)
    humanoid.WalkSpeed = 30 + speed
end
local function updateJump(jump)
    humanoid.JumpPower = 50 + jump
end
local function levelReqCheck()
    local level = plr:GetAttribute("Levels") :: number

    if plr:GetAttribute("EXP") >= floor(level ^ 1.85) + 60 then
        if lvUpCD then return end

        lvUpCD = true
        Signals.LevelUp:Fire(plr)

        wait(1)
        lvUpCD = false
    end
end
updateMinDMG()
updateMaxDMG()
updateMagic()
updateMana()
updateShield()
updateHP()
updateSpeed(0)
updateJump(0)
levelReqCheck()

Fusion.Hydrate(plr)({
    [AttributeChange("DmgPoints")] = function()
        updateMinDMG()
        updateMaxDMG()
    end,
    [AttributeChange("MagicPoints")] = updateMagic,
    [AttributeChange("ManaPoints")] = updateMana,
    [AttributeChange("ShieldPoints")] = updateShield,
    [AttributeChange("HealthPoints")] = updateHP,
    [AttributeChange("EXP")] = levelReqCheck,
    [AttributeChange("Class")] = function()
        ServerUtil:EquipWeapon(char)
    end
})

local function _shieldCheck(shield)
    local maxShield = char:GetAttribute("MaxShield")

    if shield > 0 and isBroken then isBroken = false end
    if shield >= maxShield then char:SetAttribute("Shield", maxShield) end

    if shield == 0 and not isBroken then
        isBroken = true

        Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.ShieldBroken)
    end
end
Fusion.Hydrate(char)({
    [AttributeChange("MinDMGBuff")] = updateMinDMG,
    [AttributeChange("MaxDMGBuff")] = updateMaxDMG,
    [AttributeChange("MagicBuff")] = updateMagic,
    [AttributeChange("ManaBuff")] = updateMana,
    [AttributeChange("Mana")] = manaCheck,
    [AttributeChange("ShieldBuff")] = updateShield,
    [AttributeChange("HealthBuff")] = updateHP,
    [AttributeChange("SpeedBuff")] = updateSpeed,
    [AttributeChange("JumpBuff")] = updateJump,
    [AttributeChange("Shield")] = _shieldCheck,
    [AttributeChange("InCombat")] = function(state)
        orbSpawnHandler(state)

        ServerUtil:EquipWeapon(char)
    end
})

char:SetAttribute("CharDataLoaded", true)
