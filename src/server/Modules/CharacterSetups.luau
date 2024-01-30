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
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local AttributeChange = Fusion.AttributeChange

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local wait = task.wait
local floor, random = math.floor, math.random
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local sFind = string.find

local function charTakeDMG(char: Model, monster: Model, dmgType: boolean?)
	if not monster then return end

	local humanoid = char.Humanoid
	local shield = char:GetAttribute("Shield")
	local dmg, finalDmg = monster:GetAttribute("Damage"), monster:GetAttribute("Damage")

	if monster == "Abyss" then
		char.Humanoid:TakeDamage(char.Humanoid.MaxHealth + 1)
		return
	end

    local function _cancelHealing()
        if char:GetAttribute("HitCD") < 0 then char:SetAttribute("HitCD", 1) end
        HarukaLib:Add(char, "HitCD", 15)
        if char:GetAttribute("HitCD") > 15 then char:SetAttribute("HitCD", 15) end

        if char:FindFirstChild("HealHP") then char.HealHP:Destroy() end
        if char:FindFirstChild("RepairShield") then char.RepairShield:Destroy() end
        char:SetAttribute("Repairing", false)
        char:SetAttribute("Healing", false)

        if char:GetAttribute("Shield") < char:GetAttribute("MaxShield") then
            RepS.Resources.Unloads.RepairShield:Clone().Parent = char
        end
        if humanoid.Health < humanoid.MaxHealth then
            RepS.Resources.Unloads.HealHP:Clone().Parent = char
        end
    end
    _cancelHealing()

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

local function orbSpawnHandler(char: Model, state: boolean)
    local orbFolders = workspace.MapComponents.OrbFolders
    local monster, orbAttack = char.CharStats.TargetMonster, RepS.Package.PlayerAttacks
    local plr = Players:GetPlayerFromCharacter(char)

    local function _placeOrb(orb: Model, pos: CFrame, lifeTime: number)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb:SetAttribute("OrbLifeTime", lifeTime)
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, lifeTime)
    end
    local function _spawnOrb(isSpawned: boolean?)
        local isInCombat, class, lifeTime =
            char:GetAttribute("InCombat"), plr:GetAttribute("Class"), char:GetAttribute("OrbLifeTime")

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

    local stopSpawn
    if state then
		if char:GetAttribute("SpawnMultiOrb") then
			for _ = 1, 3 do _spawnOrb(true) end
		end

		stopSpawn = Clock(3, function()
			if char:GetAttribute("InCombat") then _spawnOrb() end
		end)
	else
		if stopSpawn then stopSpawn() end
	end
end

local function weaponHandler(char: Model, state: boolean)
    local plr = Players:GetPlayerFromCharacter(char)

    for _, child in char:GetChildren() do
		if sFind(child.Name, "Weapon") then child:Destroy() end
	end

	local class = plr:GetAttribute("Class")
    if state then
        local weapon = RepS.Package.StyleWeapons[class].WeaponEquipped:Clone() :: Model

        ServerUtil:WeldPart(char["Right Arm"], weapon)
        weapon.Parent = char

        if class == "Repeater" or class == "Alchemist" then
            local weapon2 = RepS.Package.StyleWeapons[class].WeaponEquipped2:Clone() :: Model
            ServerUtil:WeldPart(char["Left Arm"], weapon2)

            weapon2.Parent = char
        end
    else
        ServerUtil:EquipWeapon(char)
    end
end

local function returnFunc(char: Model)
    local plr = Players:GetPlayerFromCharacter(char)
    local humanoid = char.Humanoid

    local charStats = nil
    local isBroken = false
    local lvUpCD, dmgTouchCD, orbTouchCD = false, false, false

    local ATTRIBUTES = {
		CriChance = 1,
		InCombat = false,
		Magic = 0,
		Mana = 0,
		Damage = 0,
		MaxMana = 0,
		MaxShield = 0,
		OrbLifeTime = 10,
		Shield = 0,
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

    repeat wait() until plr:GetAttribute("PlayerDataLoaded")
    local function _setup()
        char.PrimaryPart = char.Humanoid.RootPart

        local function __createFolder(name: string, parent: Folder) : Folder
            local folder = instanceNew("Folder")
            folder.Name = name
            folder.Parent = parent

            return folder
        end
        local function __createStats()
            charStats = __createFolder("CharStats", char)

            for i, v in ATTRIBUTES do
                char:SetAttribute(i, v)
            end
            local objValue = instanceNew("ObjectValue")
            objValue.Name = "TargetMonster"
            objValue.Parent = charStats

            __createFolder("Items", charStats)
            __createFolder("ExtraOrbs", charStats)
            __createFolder("TargetMonsters", charStats)
            __createFolder("EffectsList", charStats)
        end
        __createStats()

        humanoid.BreakJointsOnDeath = false
        char:SetAttribute("HitCD", 0)

        Clock(1, function()
            HarukaLib:Add(plr, "PlayTime", 1)

            if char:GetAttribute("HitCD") > 0 then
                HarukaLib:Add(char, "HitCD", -1)
            end
        end)

        ServerUtil:EquipWeapon(char)
    end
    local function _classAttributesSetup()
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
    _setup()
    _classAttributesSetup()

    --// Connections
    local function _onDead()
        char:SetAttribute("InCombat", false)

        for _, monster in char.CharStats.TargetMonsters:GetChildren() do
            wait()
            monster.Value.TargetingList[char.Name]:Destroy()
        end
        for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
            if orbFolder.Name == char.Name then orbFolder:Destroy() end
        end

        ServerUtil:RagdollNPC(char)
    end
    local function _onTouch(hit: BasePart)
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

            SkillUtil:RestoreManaByOrb(plr)

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

            charTakeDMG(char, damagePart.Owner.Value, damagePart:GetAttribute("Pierce"))
        end
    end
    humanoid.Died:Once(_onDead)
    humanoid.Touched:Connect(_onTouch)

    local function _manaCheck(mana)
        local maxMana = char:GetAttribute("MaxMana")

        if mana > maxMana then char:SetAttribute("Mana", maxMana) end
    end
    local function _updateDMG()
        char:SetAttribute("Damage", floor(plr:GetAttribute("DmgPoints") ^ 1.5) + 10 + char:GetAttribute("DamageBuff"))
    end
    local function _updateMagic()
        char:SetAttribute("Magic", floor(plr:GetAttribute("MagicPoints") ^ 1.42) + 20 + char:GetAttribute("MagicBuff"))
    end
    local function _updateMana()
        char:SetAttribute("MaxMana", floor(plr:GetAttribute("ManaPoints") ^ 1.9) + 100 + char:GetAttribute("ManaBuff"))
        char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
    end
    local function _updateShield()
        char:SetAttribute("MaxShield", floor(plr:GetAttribute("ShieldPoints") ^ 1.4) + 20 + char:GetAttribute("ShieldBuff"))
        char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
    end
    local function _updateHP()
        humanoid.MaxHealth = floor(plr:GetAttribute("HealthPoints") ^ 1.7) + 100 + char:GetAttribute("HealthBuff")
        humanoid.Health = humanoid.MaxHealth
    end
    local function _updateSpeed(speed)
        humanoid.WalkSpeed = 30 + speed
    end
    local function _updateJump(jump)
        humanoid.JumpPower = 50 + jump
    end
    local function _levelReqCheck()
        local level = plr:GetAttribute("Levels")

        if plr:GetAttribute("EXP") >= floor(level ^ 1.85) + 60 then
            if lvUpCD then return end

            lvUpCD = true
            Signals.LevelUp:Fire(plr)

            wait(1)
            lvUpCD = false
        end
    end
    _updateDMG()
    _updateMagic()
    _updateMana()
    _updateShield()
    _updateHP()
    _updateSpeed(0)
    _updateJump(0)
    _levelReqCheck()

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

    local function _shieldCheck(shield)
        local maxShield = char:GetAttribute("MaxShield")

        if shield < 0 then char:SetAttribute("Shield", 0) end
        if shield > 0 and isBroken then isBroken = false end
        if shield >= maxShield then char:SetAttribute("Shield", maxShield) end

        if shield == 0 and not isBroken then
            isBroken = true

            Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.ShieldBroken)
        end
    end
    Fusion.Hydrate(char)({
        [AttributeChange("DamageBuff")] = _updateDMG,
        [AttributeChange("MagicBuff")] = _updateMagic,
        [AttributeChange("ManaBuff")] = _updateMana,
        [AttributeChange("Mana")] = _manaCheck,
        [AttributeChange("ShieldBuff")] = _updateShield,
        [AttributeChange("HealthBuff")] = _updateHP,
        [AttributeChange("SpeedBuff")] = _updateSpeed,
        [AttributeChange("JumpBuff")] = _updateJump,
        [AttributeChange("Shield")] = _shieldCheck,
        [AttributeChange("InCombat")] = function(state)
            orbSpawnHandler(char, state)
            weaponHandler(char, state)
        end
    })

    char:SetAttribute("CharDataLoaded", true)
end

return returnFunc
