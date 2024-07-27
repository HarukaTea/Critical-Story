--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Signals = require(SSS.Modules.Data.ServerSignals)
local QuestUtil = require(SSS.Modules.Utils.QuestUtil)

local wait = task.wait

--// Main
local function startTheAdventure(plr: Player)
    Events.FireStoryEvents.Fire(plr, { EventSymbol = "StoryMain1" })

    wait(1)
    Events.CameraScene.Fire(plr, { Part = RepS.Package.Unloads.ResetCamera })

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

            Debris:AddItem(locator, 3)
        end
    end)
end
Signals.FirstStepTutorial:Connect(firstCombat)


local function pahoFight1(plr: Player)
    Events.PlaySound.Fire(plr, { Sound = RepS.Package.Unloads.ResetSound })
    Events.CameraScene.Fire(plr, { Part = RepS.Package.Unloads.ResetCamera })

    local locator = RepS.Package.Unloads.MonsterLocator:Clone() :: BasePart
    locator.Name = "HardmodeWolf"
    locator:SetAttribute("Levels", 5)
    locator:SetAttribute("Music", "MahouShojiu")
    locator:SetAttribute("CantRespawn", true)
    locator:SetAttribute("ExclusivePlayer", plr.Name)
    locator.Transparency = 1
    locator.CFrame = workspace.Maps.MonolithGrove.StoryLocator1.CFrame * CFrame.new(0, -1.5, 0)
    locator.Parent = workspace.Monsters

    RepS.Package.Unloads.CombatEnds:Clone().Parent = locator

    plr.Character:PivotTo(locator.CFrame)
end
Signals.PahoFight1:Connect(pahoFight1)


--// Side
local function newFactionJourney(plr: Player)
    local check = false
    for _, quest: IntValue in plr.Quests:GetChildren() do
        if quest.Name == "Side" and quest.Value == 1 then check = true break end
    end

    if not check then QuestUtil:CreateNewQuest(plr, "Side", 0) end
end
Signals.JoinFaction:Connect(newFactionJourney)


--// Town
local function gaveFurs(plr: Player)
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    inventory.SpikyFur.Value -= 6
    if inventory.SpikyFur.Value <= 0 then inventory.SpikyFur:Destroy() end
end
Signals.FChenPTown2:Connect(gaveFurs)
