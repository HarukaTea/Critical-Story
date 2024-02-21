--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local wait = task.wait
local instanceNew = Instance.new

local function firstCombat(plr: Player)
    local locator = workspace.Monsters["Primis Field"]["Spike Fox"]:Clone() :: Part
    locator:ClearAllChildren()
    locator:SetAttribute("Levels", 1)
    locator:SetAttribute("CantRespawn", true)
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
        for reward, val in StoryBook.Main[3].Rewards do
			HarukaLib:Add(plr, reward, val)
		end

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
