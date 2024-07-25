--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait

local quests = plr:WaitForChild("Quests", 999) :: Folder
local charStats = char:WaitForChild("CharStats", 999) :: Folder

--// Setups
local function questDataSetup()
    local function _detectRelativeScripts(quest: string)
        if not charStats.Quests:FindFirstChild(quest) and SS.Resources.Quests:FindFirstChild(quest) then
            SS.Resources.Quests[quest]:Clone().Parent = charStats.Quests
        end
    end
    for _, quest: IntConstrainedValue in quests:GetChildren() do
        _detectRelativeScripts(quest.Name..quest.Value)
    end

    local function setQuestsScriptsAdded(quest: IntConstrainedValue)
        _detectRelativeScripts(quest.Name..quest.Value)
    end
    local function setQuestsScriptsRemoved(quest: IntConstrainedValue)
        wait()
        local questName = quest.Name..quest.Value

        for _, child: Script in charStats.Quests:GetChildren() do
            if child.Name == questName then child:Destroy() end
        end
    end
    Add(quests.ChildAdded:Connect(setQuestsScriptsAdded))
    Add(quests.ChildRemoved:Connect(setQuestsScriptsRemoved))
end
questDataSetup()

--// Clear
char.Humanoid.Died:Once(Empty)
