--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local playerDatas = {}
local playerScopes = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local DATASTORE = require(SSS.Modules.Data.DatastoreTemplate)

local newInstance = Instance.new
local wait = task.wait
local time = os.time
local format, match = string.format, string.match
local tFind = table.find

local function _findDataStore(plr: Player) : DataStore
	local joinData = plr:GetJoinData().TeleportData :: table?
	local slotChosen = if joinData then joinData[1] else "Slot1"
	local realSlot = tonumber(match(slotChosen, "%d")) or 1

	return DSS:GetDataStore(DATASTORE[realSlot])
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

	data.Inventory = inventory
	data.QuestsV2 = quests
end
local function _deepCopyTable(t: table) : table
	local copy = {}

	for k, v in pairs(t) do
		if type(v) == "table" then copy[k] = _deepCopyTable(v) else copy[k] = v end
	end

	return copy
end
local function _reconcile(data: table, template: table)
	for k, v in pairs(template) do
		if type(k) == "string" then --- only string keys will be reconciled
			if data[k] == nil then
				if type(v) == "table" then data[k] = _deepCopyTable(v) else data[k] = v end

			elseif type(data[k]) == "table" and type(v) == "table" then
				_reconcile(data[k], v)
			end
		end
	end
end


local function setup(plr: Player)
	local data = _findDataStore(plr):GetAsync(plr.UserId) or TEMPLATE

	_reconcile(data, TEMPLATE)

	playerDatas[plr.Name] = data
	local Add, Empty = HarukaLib.Bin()
	playerScopes[plr.Name] = Empty

	local backpackData = newInstance("Folder")
	backpackData.Name = "Inventory"
	backpackData.Parent = plr

	local questsData = newInstance("Folder")
	questsData.Name = "Quests"
	questsData.Parent = plr

	---// Load stats
	local blacklist = { "V9Transfered" }
	for attr: string, val: any in data.Stats do
		if tFind(blacklist, attr) then continue end

		pcall(function()
			plr:SetAttribute(attr, HarukaLib:Deserialize(val))
		end)

		Add(HarukaLib:Hydrate(plr, {
			["Attr-"..attr] = function(newStats: any)
				if newStats == nil then return end --// We have false boolean data

				data.Stats[attr] = HarukaLib:Serialize(newStats)
			end
		}))
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
	for index: string, info: table in data.Inventory do
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
	Add(backpackData.ChildAdded:Connect(_save))
	Add(backpackData.ChildRemoved:Connect(_save))
	Add(questsData.ChildAdded:Connect(_save))
	Add(questsData.ChildRemoved:Connect(_save))

	--// Finish
	plr:SetAttribute("PlayerDataLoaded", true)
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
	if not playerDatas[plr.Name] then return end

	_saveData(plr)
	_findDataStore(plr):SetAsync(plr.UserId, playerDatas[plr.Name])

	playerDatas[plr.Name] = nil
	playerScopes[plr.Name]()
end

--- in case player joined before server starts
for _, plr in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)
