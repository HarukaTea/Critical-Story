--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(SSS.Modules.Data.ServerEvents)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local charStats = nil
local isBroken = false
local lvUpCD = false

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

local wait = task.wait
local floor, random = math.floor, math.random
local instanceNew = Instance.new
local sFind = string.find


local stopSpawn
local function orbSpawnHandler(state: boolean)
    local orbFolders = workspace.MapComponents.OrbFolders :: Folder

    local function _placeOrb(orb: Model, pos: CFrame, lifeTime: number)
        orb.Owner.Value = char
        orb:PivotTo(pos)
        orb:SetAttribute("OrbLifeTime", lifeTime)
        orb.Parent = orbFolders[char.Name]

        Debris:AddItem(orb, lifeTime)
    end
    local function _spawnOrb(isSpawned: boolean?)
        local monster, orbAttack = char.CharStats.TargetMonster :: ObjectValue, RepS.Package.PlayerAttacks :: Folder
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

                    _placeOrb(orbAttack[attr]:Clone(), ServerUtil:GenerateOrbPos(monster.Value), lifeTime)
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
        _createFolder("Quests", charStats)
    end
    _createStats()

    ServerUtil:SetCollisionGroup(char, "Player")

    humanoid.BreakJointsOnDeath = false
    Clock(1, function()
        HarukaLib:Add(plr, "PlayTime", 1)

        if char:GetAttribute("HitCD") >= 0 then HarukaLib:Add(char, "HitCD", -1) end
    end)

    --// Spawn to the nearest respawn point
    if not RS:IsStudio() then
        local spawnPoint = ServerUtil:FindNearestSpawn(plr)

        char:PivotTo(spawnPoint.CFrame)
        plr:SetAttribute("LastLocation", spawnPoint.Position)
    end

    char:SetAttribute("CharDataLoaded", true)
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

local function questDataSetup()
    local quests = plr:WaitForChild("Quests", 999) :: Folder

    for _, quest: IntConstrainedValue in quests:GetChildren() do
        if StoryBook[quest.Name][quest.Value]["Script"] then
            RepS.Resources.Quests[quest.Name..quest.Value]:Clone().Parent = char.CharStats.Quests
        end
    end

    local function setQuestsScriptsAdded(quest: IntConstrainedValue)
        local questName = quest.Name..quest.Value

        if StoryBook[quest.Name][quest.Value]["Script"] and not char.CharStats.Quests:FindFirstChild(questName) then
            RepS.Resources.Quests[questName]:Clone().Parent = char.CharStats.Quests
        end
    end
    local function setQuestsScriptsRemoved(quest: IntConstrainedValue)
        wait()
        local questName = quest.Name..quest.Value

        for _, child in char.CharStats.Quests:GetChildren() do
            if sFind(child.Name, questName) then child:Destroy() end
        end
    end
    quests.ChildAdded:Connect(setQuestsScriptsAdded)
    quests.ChildRemoved:Connect(setQuestsScriptsRemoved)
end
questDataSetup()

--// Connections
local function onDead()
    if char.PrimaryPart then plr:SetAttribute("LastLocation", char.PrimaryPart.Position) end
    char:SetAttribute("InCombat", false)

    for _, monster in char.CharStats.TargetMonsters:GetChildren() do
        monster.Value.TargetingList[char.Name]:Destroy()
    end
    for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
        if orbFolder.Name == char.Name then orbFolder:Destroy() end
    end

    ServerUtil:RagdollNPC(char)
end
humanoid.Died:Once(onDead)

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
    char:SetAttribute("MaxMana", floor(plr:GetAttribute("ManaPoints") * 60) + 100 + char:GetAttribute("ManaBuff"))
    char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
end
local function updateShield()
    char:SetAttribute("MaxShield", floor(plr:GetAttribute("ShieldPoints") * 20) + 20 + char:GetAttribute("ShieldBuff"))
    char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
end
local function updateHP()
    humanoid.MaxHealth = floor(plr:GetAttribute("HealthPoints") * 80) + 100 + char:GetAttribute("HealthBuff")
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
