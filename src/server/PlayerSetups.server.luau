--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local DS1, DS2, DS3 = "CS_AS03_T1", "CS_AS03_T1_S2", "CS_AS03_T1_S3"

local newInstance = Instance.new
local wait = task.wait
local tFind = table.find

local function findDataStore(plr: Player) : DataStore?
	local joinData = plr:GetJoinData().TeleportData :: table?
	local slotChosen = if joinData then joinData[1] else "Slot1"

	local ds: DataStore
	if slotChosen == "Slot2" then
		ds = SuphiDataStore.find(DS2, plr.UserId)
	elseif slotChosen == "Slot3" then
		ds = SuphiDataStore.find(DS3, plr.UserId)
	else
		ds = SuphiDataStore.find(DS1, plr.UserId)
	end

	return ds
end

local function _saveData(plr: Player, ds: any)
	local data = ds.Value :: table
	if not data then return end

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
	data.Quests = quests
end

local function setup(plr: Player)
	local joinData = plr:GetJoinData().TeleportData :: table?
	local slotChosen = if joinData then joinData[1] else "Slot1"

	local ds: DataStore
	if slotChosen == "Slot2" then
		ds = SuphiDataStore.new(DS2, plr.UserId)
	elseif slotChosen == "Slot3" then
		ds = SuphiDataStore.new(DS3, plr.UserId)
	else
		ds = SuphiDataStore.new(DS1, plr.UserId)
	end

	local function _stateChanged(_, datastore: any)
		while datastore.State == false do
			if datastore:Open(TEMPLATE) ~= "Success" then wait(6) end
		end
	end
	ds.StateChanged:Connect(_stateChanged)
	_stateChanged(ds.State, ds)

	--- once everything is fine, we load data
	local data = ds.Value :: table

	local backpackData = newInstance("Folder")
	backpackData.Name = "Inventory"
	backpackData.Parent = plr
	local questsData = newInstance("Folder")
	questsData.Name = "Quests"
	questsData.Parent = plr

	---// Load stats
	local blackList = { "LastLocation" } --- deprecated data but stored in the same table
	for attr: string, val: any in data.Stats do
		if tFind(blackList, attr) then continue end

		plr:SetAttribute(attr, HarukaLib:Deserialize(val))

		HarukaLib:Hydrate(plr, {
			["Attr-"..attr] = function(newStats: any)
				if newStats == nil then return end --// We have false boolean data

				data.Stats[attr] = HarukaLib:Serialize(newStats)
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
	for questType: string, questId: number in data.Quests do
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
		intValue.MaxValue = ItemBook:FindItem(index).MaxAmount
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
		_saveData(plr, ds)
	end
	backpackData.ChildAdded:Connect(_save)
	backpackData.ChildRemoved:Connect(_save)

	--// Finish
	plr:SetAttribute("PlayerDataLoaded", true)
end

local function clear(plr: Player)
	local ds = findDataStore(plr)

	if ds then
		_saveData(plr, ds)
		ds:Destroy()
	end

	--- check if player is combating
	pcall(function()
		for _, monster: Instance in workspace.Monsters:GetDescendants() do
			if monster:HasTag("Monster") and monster.PrimaryPart then
				if not monster:FindFirstChild("TargetPlayers") then continue end

				if monster.TargetPlayers:FindFirstChild(plr.Name) then
					monster.TargetPlayers[plr.Name]:Destroy()

					print(plr.Name .. " left during combat with " .. monster.Name)
				end
			end
		end
	end)
end

--- in case player joined before server starts
for _, plr in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
local function _playerAdded(plr: Player)
	if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
		setup(plr)
	end
end
Players.PlayerAdded:Connect(_playerAdded)
Players.PlayerRemoving:Connect(clear)
