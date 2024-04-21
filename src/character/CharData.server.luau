--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Bin = require(RepS.Modules.Packages.Bin)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(SSS.Modules.Data.ServerEvents)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local isBroken = false
local lvUpCD = false

local AttributeChange = Fusion.AttributeChange

local ATTRIBUTES = require(SSS.Modules.Data.CharTemplate)

local wait = task.wait
local floor, random = math.floor, math.random
local instanceNew = Instance.new
local sFind = string.find


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
        local charStats = _createFolder("CharStats", char)

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
    Add(Clock(1, function()
        HarukaLib:Add(plr, "PlayTime", 1)
    end))

    --// Spawn to the nearest respawn point
    if not RS:IsStudio() then
        local spawnPoint = ServerUtil:FindNearestSpawn(plr)

        char:PivotTo(spawnPoint.CFrame)
        plr:SetAttribute("LastLeave", spawnPoint.Position)
    end

    char:SetAttribute("CharDataLoaded", true)
end
Spawn(setup)

local function classAttributesSetup()
    --- warrior
    Add(char.Humanoid.StateChanged:Connect(function(state)
        if state == Enum.HumanoidStateType.Landed
            or state ~= Enum.HumanoidStateType.Jumping
            or state ~= Enum.HumanoidStateType.Freefall
        then
            char:SetAttribute("Combo", 0)
        end
    end))

    --- wizard
    Add(char:GetAttributeChangedSignal("InCombat"):Connect(function()
        if not char:GetAttribute("InCombat") then
            char:SetAttribute("WizardCasted", 0)
            char:SetAttribute("Guard", 0)
            char:SetAttribute("RogueCritical", 0)
            char:SetAttribute("ResearchStage", 0)
        end
    end))

    --- knight
    Add(Clock(1.1, function()
        if char:GetAttribute("Guard") <= 0 then return end

        HarukaLib:Add(char, "Guard", -1)
    end))

    --- rogue
    Add(Clock(0.7, function()
        if char:GetAttribute("RogueCritical") <= 0 then return end

        HarukaLib:Add(char, "RogueCritical", -1)
    end))
end
Spawn(classAttributesSetup)

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
    Add(quests.ChildAdded:Connect(setQuestsScriptsAdded))
    Add(quests.ChildRemoved:Connect(setQuestsScriptsRemoved))
end
Spawn(questDataSetup)

--// Connections
local function onDead()
    Empty()

    if char.PrimaryPart then plr:SetAttribute("LastLeave", char.PrimaryPart.Position) end
    char:SetAttribute("InCombat", false)

    for _, monster in char.CharStats.TargetMonsters:GetChildren() do
        if not monster.Value then continue end
        if not monster.Value:FindFirstChild("TargetingList") then continue end
        if not monster.Value.TargetingList:FindFirstChild(char.Name) then continue end

        monster.Value.TargetingList[char.Name]:Destroy()
    end
    for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
        if orbFolder.Name == char.Name then orbFolder:Destroy() end
    end

    ServerUtil:RagdollNPC(char)
end
humanoid.Died:Once(onDead)

local function tpCheck(tp: number)
    if tp > 100 then char:SetAttribute("TP", 100) end
end
local function shieldCheck(shield: number)
    local maxShield = char:GetAttribute("MaxShield")

    if shield > 0 and isBroken then isBroken = false end
    if shield >= maxShield then char:SetAttribute("Shield", maxShield) end

    if shield == 0 and not isBroken then
        isBroken = true

        Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.ShieldBroken)
    end
end

local function updateATK()
    char:SetAttribute("ATKDMG", floor(plr:GetAttribute("ATKPoints") ^ 1.5) + 10 + char:GetAttribute("ATKDMGBuff"))
end
local function updateShield()
    char:SetAttribute("MaxShield", floor(plr:GetAttribute("ShieldPoints") * 5) + 5 + char:GetAttribute("ShieldBuff"))
    char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
end
local function updateHP()
    humanoid.MaxHealth = floor(plr:GetAttribute("HealthPoints") * 80) + 80 + char:GetAttribute("HealthBuff")
    humanoid.Health = humanoid.MaxHealth
end
local function updateSpeed(speed: number)
    humanoid.WalkSpeed = 30 + speed
end
local function updateJump(jump: number)
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
updateATK()
updateShield()
updateHP()
updateSpeed(0)
updateJump(0)
levelReqCheck()

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

Fusion.Hydrate(plr)({
    [AttributeChange("ATKPoints")] = updateATK,
    [AttributeChange("ShieldPoints")] = updateShield,
    [AttributeChange("HealthPoints")] = updateHP,
    [AttributeChange("EXP")] = levelReqCheck,
    [AttributeChange("Class")] = function()
        ServerUtil:EquipWeapon(char)
    end
})
Fusion.Hydrate(char)({
    [AttributeChange("TP")] = tpCheck,
    [AttributeChange("ShieldBuff")] = updateShield,
    [AttributeChange("HealthBuff")] = updateHP,
    [AttributeChange("SpeedBuff")] = updateSpeed,
    [AttributeChange("JumpBuff")] = updateJump,
    [AttributeChange("Shield")] = shieldCheck,
    [AttributeChange("InCombat")] = function(state: boolean)
        orbSpawnHandler(state)

        ServerUtil:EquipWeapon(char)
    end
})
