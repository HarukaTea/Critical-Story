--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local StoryBook = require(ReplicatedStorage.Modules.Data.StoryBook)

local QuestUtil = {}


function QuestUtil:GiveQuestRewards(series: string, questId: number, plr: Player)
	for reward: string, val: number in StoryBook[series][questId].Rewards do
		HarukaLib:AddAttr(plr, reward, val)

		ServerUtil:ShowText(plr.Character, "+"..val.." "..reward, Color3.fromRGB(212, 255, 0))
	end
end


function QuestUtil:CreateNewQuest(plr: Player, series: string, questId: number)
    local newQuest = Instance.new("IntConstrainedValue")
	newQuest.Name = series
	newQuest.MinValue = 1
	newQuest.MaxValue = #StoryBook[series]
	newQuest.Value = questId + 1
	newQuest.Parent = plr.Quests
end


return QuestUtil
