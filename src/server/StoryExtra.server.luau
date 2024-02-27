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
local function firstCombat(plr: Player)
    local locator = workspace.Monsters["Primis Field"]["Green Slime"]:Clone() :: Part
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", 1)
    locator:SetAttribute("CantRespawn", true)
    locator:SetAttribute("MusicId", "Conquest")
    locator.CFrame = workspace.Maps["Initus Village"].TutorialLocator.CFrame
    locator.Parent = workspace.Monsters

    local monster = ServerUtil:SetupMonster(locator)

    plr.Character:PivotTo(locator.CFrame)

    local huamnoid = plr.Character.Humanoid
    repeat
        wait()
        if not monster then return end
    until monster:GetAttribute("Health") <= 0 or huamnoid.Health <= 0

    if monster:GetAttribute("Health") <= 0 then
        ServerUtil:GiveQuestRewards("Main", 3, plr)

		plr.Quests.Main:Destroy()

		local quest = instanceNew("IntConstrainedValue")
		quest.Name = "Main"
		quest.MinValue = 1
		quest.MaxValue = #StoryBook.Main
		quest.Value = 4
		quest.Parent = plr.Quests

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

        if not plr.Quests:FindFirstChild("Side") then
            local sideQuest = instanceNew("IntConstrainedValue")
            sideQuest.Name = "Side"
            sideQuest.MinValue = 1
            sideQuest.MaxValue = #StoryBook.Side
            sideQuest.Value = 1
            sideQuest.Parent = plr.Quests
        end
    end
end
Signals.FirstStepTutorial:Connect(firstCombat)

local function afterInitusBay(plr: Player)
    Signals.QuestComplete:Fire("Main", 8, plr, true)

    wait(2)
    Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.RareItemAcquired)

    ServerUtil:GiveItem(plr, "HeheLetter", 1)
end
Signals.CompletedInitusBay:Connect(afterInitusBay)

--// Town
local function gaveFurs(plr: Player)
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    inventory.SpikyFur.Value -= 6
    if inventory.SpikyFur.Value <= 0 then inventory.SpikyFur:Destroy() end
end
Signals.FChenPTown2:Connect(gaveFurs)
