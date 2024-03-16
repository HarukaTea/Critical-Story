--!strict

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Hydrate, AttributeChange = Fusion.Hydrate, Fusion.AttributeChange

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local DS1, DS2, DS3 = "CS_DEV1599", "CS_DEV1599_S2", "CS_DEV1599_S3"

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
	local equipped = {}
	local pinned = {}
	local quests, townQuests = {}, {}

	for index, item in plr.Inventory:GetChildren() do
		if item.Value <= 0 then continue end

		inventory[item.Name] = item.Value

		if item:GetAttribute("Pinned") then pinned[index] = item.Name end
		if item:GetAttribute("Equipped") then equipped[item.Name] = item:GetAttribute("Slot") end
	end
	for _, quest in plr.Quests:GetChildren() do
		if quest.Name == "Town" then
			townQuests[#townQuests + 1] = quest.Value
			continue
		end

		quests[quest.Name] = quest.Value
	end
	quests.Town = townQuests

	data.Inventory = inventory
	data.EquippedItems = equipped
	data.PinnedItems = pinned
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

	local function stateChanged(state: boolean, datastore: any)
		while datastore.State == false do
			if datastore:Open(TEMPLATE) ~= "Success" then wait(6) end
		end
	end
	ds.StateChanged:Connect(stateChanged)
	stateChanged(ds.State, ds)

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
	for attr, val in data.Stats do
		if tFind(blackList, attr) then continue end

		plr:SetAttribute(attr, HarukaLib:Deserialize(val))

		Hydrate(plr)({
			[AttributeChange(attr)] = function(newStat: any)
				if newStat == nil then return end

				data.Stats[attr] = HarukaLib:Serialize(newStat)
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
	for questType, questId in data.Quests do
		if questType == "Town" then
			for _, townQuest: number in questId do _createQuestVal("Town", townQuest) end
			continue
		end

		_createQuestVal(questType, questId)
	end

	--// Load items
	local function _createItemVal(name: string, maxVal: number, val: number)
		local intValue = newInstance("IntConstrainedValue")
		intValue.Name = name
		intValue.MaxValue = maxVal
		intValue.Value = val
		intValue.Parent = backpackData
	end
	for index: string, amount: number in data.Inventory do
		if AssetBook.Items.ItemName[index] then
			local itemType = AssetBook.Items.ItemType[index]

			if not AssetBook.Items.IsSkill[index] and (itemType == "Active" or itemType == "Material") then
				_createItemVal(index, 9999, amount)
			else
				_createItemVal(index, 1, amount)
			end
		end
	end
	for item, slot in data.EquippedItems do
		if AssetBook.Items.ItemName[item] and backpackData:FindFirstChild(item) then
			backpackData[item]:SetAttribute("Equipped", true)
			backpackData[item]:SetAttribute("Slot", slot)
		end
	end
	for _, item in data.PinnedItems do
		if AssetBook.Items.ItemName[item] and backpackData:FindFirstChild(item) then
			backpackData[item]:SetAttribute("Pinned", true)
		end
	end

	--// Load settings
	for setting, val in data.Settings do
		plr:SetAttribute(setting, val)

		Hydrate(plr)({
			[AttributeChange(setting)] = function(newSetting: any)
				if newSetting == nil then return end

				data.Settings[setting] = newSetting
			end
		})
	end

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
	for _, monster in workspace.Monsters:GetDescendants() do
		if monster:GetAttribute("IsEnemy") then
			if monster.TargetingList:FindFirstChild(plr.Name) then
				monster.TargetingList[plr.Name]:Destroy()

				print(plr.Name .. " left during combat with " .. monster.Name)
			end
		end
	end

	--- check if player is in party
	local check = workspace.MapComponents.Parties:FindFirstChild(plr.Name, true)

	local function _leaveParty(wholeParty: Folder, member: ObjectValue)
		member:Destroy()

		for _, player in wholeParty:GetChildren() do
			Events.CreateHint:Fire(player.Value, plr.Name.." has left the party...", "Hint")
		end

		if #wholeParty:GetChildren() <= 1 then
			local player = wholeParty:FindFirstChildOfClass("ObjectValue")

			player.Value:SetAttribute("InParty", false)
			Events.CreateHint:Fire(player.Value, "The party has been disbanded due to the lack of people...", "Hint")

			wholeParty:Destroy()
		end
	end
	if check then
		if check:IsA("ObjectValue") then
			_leaveParty(check.Parent, check)

		elseif check:IsA("Folder") then
			_leaveParty(check, check[plr.Name])
		end
	end
end

--- in case player joined before server starts
for _, plr in Players:GetPlayers() do
	Spawn(function()
		setup(plr)
	end)
end

--// Connections
local function _playerAdded(plr: Player)
	if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
		setup(plr)
	end
end
Players.PlayerAdded:Connect(_playerAdded)
Players.PlayerRemoving:Connect(clear)
