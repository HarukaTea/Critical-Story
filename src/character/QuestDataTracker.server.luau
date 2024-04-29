--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Bin = require(RepS.Modules.Packages.Bin)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local Add, Empty = Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait
local sFind = string.find

--// Connections
char.Humanoid.Died:Once(Empty)

--// Setups
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

        for _, child: Script in char.CharStats.Quests:GetChildren() do
            if sFind(child.Name, questName) then child:Destroy() end
        end
    end
    Add(quests.ChildAdded:Connect(setQuestsScriptsAdded))
    Add(quests.ChildRemoved:Connect(setQuestsScriptsRemoved))
end
questDataSetup()
