--!nocheck

local DSS = game:GetService("DataStoreService")
local MS = game:GetService("MessagingService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local playerDatas = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local DATASTORE = require(SSS.Modules.Data.DatastoreTemplate)

local newInstance = Instance.new
local wait = task.wait
local time = os.time
local format = string.format

local function _findDataStore(plr: Player) : DataStore
	local joinData = plr:GetJoinData().TeleportData :: table?
	local slotChosen = if joinData then joinData[1] else "Slot1"

	local ds
	if slotChosen == "Slot2" then
		ds = DSS:GetDataStore(DATASTORE[2])
	elseif slotChosen == "Slot3" then
		ds = DSS:GetDataStore(DATASTORE[3])
	else
		ds = DSS:GetDataStore(DATASTORE[1])
	end

	return ds
end
local function _saveData(plr: Player)
	local data = playerDatas[plr.Name]
	local inventory = {}
	local quests, townQuests = {}, {}

	for _, item: IntValue in plr.Inventory:GetChildren() do
		if item.Value <= 0 then continue end

		local info = {
			Amount = item.Value,
			Equipped = item:GetAttribute("Equipped") or false,
			Pinned = item:GetAttribute("Pinned") or false,
			Slot = item:GetAttribute("Slot") or "None"
		}
		inventory[item.Name] = info
	end
	for _, quest: IntConstrainedValue in plr.Quests:GetChildren() do
		if quest.Name == "Town" then
			townQuests[#townQuests + 1] = quest.Value
		else
			quests[quest.Name] = quest.Value
		end
	end
	quests.Town = townQuests

	data.InventoryV2 = inventory
	data.QuestsV2 = quests
end


local function setup(plr: Player)
	local data = _findDataStore(plr):GetAsync(plr.UserId)

	playerDatas[plr.Name] = data

	local backpackData = newInstance("Folder")
	backpackData.Name = "Inventory"
	backpackData.Parent = plr
	local questsData = newInstance("Folder")
	questsData.Name = "Quests"
	questsData.Parent = plr

	---// Load stats
	for attr: string, val: any in data.StatsV2 do
		plr:SetAttribute(attr, HarukaLib:Deserialize(val))

		HarukaLib:Hydrate(plr, {
			["Attr-"..attr] = function(newStats: any)
				if newStats == nil then return end --// We have false boolean data

				data.StatsV2[attr] = HarukaLib:Serialize(newStats)
			end
		})
	end

	--// Load quests
	local function _createQuestVal(questType: string, val: number)
		local intValue = newInstance("IntConstrainedValue")
		intValue.Name = questType
		intValue.MinValue = 1
		intValue.MaxValue = #StoryBook[questType]
		intValue.Value = val
		intValue.Parent = questsData
	end
	for questType: string, questId: number in data.QuestsV2 do
		if questType == "Town" then
			for _, townQuest: number in questId do _createQuestVal("Town", townQuest) end
			continue
		end

		_createQuestVal(questType, questId)
	end

	--// Load items
	for index: string, info: table in data.InventoryV2 do
		if not ItemBook:IsItemExist(index) then continue end

		local intValue = newInstance("IntConstrainedValue")
		intValue.Name = index
		intValue.MaxValue = if ItemBook:FindItem(index).IsSkill then 1 else 999
		intValue.Value = info.Amount
		if info.Equipped then
			intValue:SetAttribute("Equipped", true)
			intValue:SetAttribute("Slot", info.Slot)
		end
		if info.Pinned then intValue:SetAttribute("Pinned", true) end
		intValue.Parent = backpackData
	end

	--// Load settings
	for setting: string, val: any in TEMPLATE.Settings do plr:SetAttribute(setting, val) end

	--// Connections
	local function _save()
		wait()
		_saveData(plr)
	end
	backpackData.ChildAdded:Connect(_save)
	backpackData.ChildRemoved:Connect(_save)

	--// Finish
	plr:SetAttribute("PlayerDataLoaded", true)

	--// Check if banned
	local banInfo = data.BanStats :: table
	if banInfo.IsBanned then
		local timeGap = (time() - banInfo.BannedTime) / 60 / 60

		if timeGap < banInfo.Duration then
			local durationLeft = format("%.1f", tostring(banInfo.Duration - timeGap))

			plr:Kick("You got banned! Reason: "..banInfo.Reason..", unban in "..durationLeft.." hours!")
		else
			--// unban
			data.BanStats = TEMPLATE.BanStats
		end
	end
end

local function clear(plr: Player)
	--- check if player is combating
	pcall(function()
		for _, monster: Instance in workspace.Monsters:GetDescendants() do
			if monster:HasTag("Monster") and monster.PrimaryPart then
				pcall(function()
					if monster.TargetPlayers:FindFirstChild(plr.Name) then
						monster.TargetPlayers[plr.Name]:Destroy()

						print(plr.Name .. " left during combat with " .. monster.Name)
					end
				end)
			end
		end
	end)

	pcall(function()
		_findDataStore(plr):SetAsync(plr.UserId, playerDatas[plr.Name])
	end)

	playerDatas[plr.Name] = nil
end

--- in case player joined before server starts
for _, plr in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)

--// Server setup
MS:SubscribeAsync("BanRequest", function(message: table)
	local data = message.Data :: table
	local plrName, duration, reason = data[1] :: string, data[2] :: number, data[3] :: string

	if not Players:FindFirstChild(plrName) then return end
	local cheater = Players[plrName] :: Player

	local banInfo = {
		IsBanned = true,
		Duration = duration,
		BannedTime = time(),
		Reason = reason
	}
	playerDatas[plrName].BanStats = banInfo

	cheater:Kick("You've got banned! Reason: "..reason..", Duration: "..duration.." Hours!")
end)
