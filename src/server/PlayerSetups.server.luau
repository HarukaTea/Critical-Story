--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)
local Signals = require(SSS.Modules.Data.ServerSignals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local TEMPLATE = {
	Stats = {
		Levels = 1,
		EXP = 0,
		Gold = 0,
		RP = 0,
		PlayTime = 0,
		StoryId = 0,
		Class = "Warrior",
		ChestOpened = 0,
		LastSeen = "MainWorld",
		Cosmetic = "None",
		Companion = "None",
		LvPoints = 0,
		DmgPoints = 0,
		MagicPoints = 0,
		ManaPoints = 0,
		HealthPoints = 0,
		ShieldPoints = 0,
	},
	Inventory = {},
	EquippedItems = {},
	PinnedItems = {}
}
local DS1, DS2, DS3 = "CSTORY_DEV20", "CSTORY_DEV20_S2", "CSTORY_DEV20_S3"

local newInstance = Instance.new
local wait = task.wait


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

local function _saveBackpackData(plr: Player, ds: any)
	local data = ds.Value :: table
	if not data then return end

	local inventory = {}
	local equipped = {}
	local pinned = {}

	for index, item in plr.Inventory:GetChildren() do
		if item.Value <= 0 then continue end

		inventory[item.Name] = item.Value

		if item:GetAttribute("Pinned") then pinned[index] = item.Name end
		if item:GetAttribute("Equipped") then equipped[item.Name] = item:GetAttribute("Slot") end
	end

	data.Inventory = inventory
	data.EquippedItems = equipped
	data.PinnedItems = pinned
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

	for i, v in data.Stats do
		plr:SetAttribute(i, v)

		plr:GetAttributeChangedSignal(i):Connect(function()
			data.Stats[i] = plr:GetAttribute(i)
		end)
	end

	for index, amount in data.Inventory do
		if AssetBook.Items.ItemName[index] then
			local itemType = AssetBook.Items.ItemType[index]

			if not AssetBook.Items.IsSkill[index] and (itemType == "Active" or itemType == "Material") then
				local intValue = newInstance("IntConstrainedValue")
				intValue.Name = index
				intValue.MaxValue = 9999
				intValue.Value = amount
				intValue.Parent = backpackData

			else
				local intValue = newInstance("IntConstrainedValue")
				intValue.Name = index
				intValue.MaxValue = 1
				intValue.Value = amount
				intValue.Parent = backpackData
			end
		end
	end
	for item, slot in data.EquippedItems do
		if AssetBook.Items.ItemName[item] then
			backpackData[item]:SetAttribute("Equipped", true)
			backpackData[item]:SetAttribute("Slot", slot)
		end
	end
	for _, item in data.PinnedItems do
		if AssetBook.Items.ItemName[item] then
			backpackData[item]:SetAttribute("Pinned", true)
		end
	end

	plr:SetAttribute("PlayerDataLoaded", true)
	plr:SetAttribute("InviteAccess", true)

	local function _saveData(player: Player)
		if player ~= plr then return end

		_saveBackpackData(plr, ds)
	end
	Signals.ItemsAdded:Connect(_saveData)
	Signals.ItemsEquipped:Connect(_saveData)
	Signals.ItemsPinned:Connect(_saveData)
end

local function clear(plr: Player)
	local ds = findDataStore(plr)

	if ds then
		_saveBackpackData(plr, ds)
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
