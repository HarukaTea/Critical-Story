--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local wait = task.wait
local instanceNew = Instance.new

--// Main
local function startTheAdventure(plr: Player)
    Events.StoryEvents:Fire(plr, "StoryMain1")

    wait(1)
    Events.LockCam:Fire(plr, "Reset")

    wait(3)
    Signals.QuestComplete:Fire("Main", 1, plr, true)
end
Signals.StoryMain1:Connect(startTheAdventure)


local function firstCombat(plr: Player)
    local locator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
    locator.Name = "GreenSlime"
    locator:SetAttribute("Levels", 1)
    locator:SetAttribute("CantRespawn", true)
    locator.CFrame = workspace.Maps.MonolithVillage.TutorialLocator.CFrame
    locator.Parent = workspace.Monsters

    RepS.Package.Unloads.CombatEnds:Clone().Parent = locator

    local monster = ServerUtil:SetupMonster(locator)
    plr.Character:PivotTo(locator.CFrame)

    locator.CombatEnds.Event:Connect(function()
        if monster:GetAttribute("Health") <= 0 then Signals.QuestComplete:Fire("Main", 4, plr, true) end
    end)
end
Signals.FirstStepTutorial:Connect(firstCombat)

