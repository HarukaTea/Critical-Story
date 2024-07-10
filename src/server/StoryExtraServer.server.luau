--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local wait = task.wait

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
    locator:SetAttribute("ExclusivePlayer", plr.Name)
    locator.Transparency = 1
    locator.CFrame = workspace.Maps.MonolithVillage.TutorialLocator.CFrame
    locator.Parent = workspace.Monsters

    RepS.Package.Unloads.CombatEnds:Clone().Parent = locator

    plr.Character:PivotTo(locator.CFrame)

    locator.CombatEnds.Event:Connect(function()
        if locator:FindFirstChildOfClass("Model"):GetAttribute("Health") <= 0 then
            Signals.QuestComplete:Fire("Main", 4, plr, true)
        end
    end)
end
Signals.FirstStepTutorial:Connect(firstCombat)

--// Side
local function newFactionJourney(plr: Player)
    print("1")
    local check = false
    for _, quest: IntValue in plr.Quests:GetChildren() do
        if quest.Name == "Side" and quest.Value == 1 then check = true break end
    end

    if not check then
        print("2")
        local intValue = Instance.new("IntConstrainedValue")
        intValue.Name = "Side"
        intValue.MinValue = 1
        intValue.MaxValue = #StoryBook.Side
        intValue.Value = 1
        intValue.Parent = plr.Quests
    end
end
Signals.JoinFaction:Connect(newFactionJourney)

--// Town
local function gaveFurs(plr: Player)
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    inventory.SpikyFur.Value -= 6
    if inventory.SpikyFur.Value <= 0 then inventory.SpikyFur:Destroy() end
end
Signals.FChenPTown2:Connect(gaveFurs)
