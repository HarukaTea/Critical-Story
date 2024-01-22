--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local FastSpawn = require(RepS.Modules.Packages.Spawn)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)
local Signals = require(SSS.Modules.Data.ServerSignals)

local newInstance = Instance.new
local wait = task.wait

local PlayerSetups = {}
PlayerSetups.__index = PlayerSetups

--[[
	Finds the datastore with the given `player` object
]]
function PlayerSetups:FindDataStore(plr: Player) : DataStore?
	local joinData = plr:GetJoinData().TeleportData
	local slotChosen = if joinData then joinData[1] else "Slot1"

	local ds
	if slotChosen == "Slot2" then
		ds = SuphiDataStore.find(self.DS2, plr.UserId)
	elseif slotChosen == "Slot3" then
		ds = SuphiDataStore.find(self.DS3, plr.UserId)
	else
		ds = SuphiDataStore.find(self.DS1, plr.UserId)
	end

	return ds
end

--[[
	Cache the backpack data to datastore, and wait autosave
]]
function PlayerSetups:SaveBackpackData(plr: Player, ds: any)
	local data = ds.Value
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

--[[
	Load the data from DataStore and apply attributes to player
]]
function PlayerSetups:Setup(plr: Player)
	local joinData = plr:GetJoinData().TeleportData
	local slotChosen = if joinData then joinData[1] else "Slot1"

	local ds
	if slotChosen == "Slot2" then
		ds = SuphiDataStore.new(self.DS2, plr.UserId)
	elseif slotChosen == "Slot3" then
		ds = SuphiDataStore.new(self.DS3, plr.UserId)
	else
		ds = SuphiDataStore.new(self.DS1, plr.UserId)
	end

	local function stateChanged(state: boolean, datastore: any)
		while datastore.State == false do
			if datastore:Open(self.TEMPLATE) ~= "Success" then wait(6) end
		end
	end
	ds.StateChanged:Connect(stateChanged)
	stateChanged(ds.State, ds)

	--- once everything is fine, we load data
	local data = ds.Value

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

	plr:SetAttribute("PlayerSpawnPos", Vector3.zero)
	plr:SetAttribute("PlayerDataLoaded", true)

	local function saveData(player: Player)
		if player ~= plr then return end

		self:SaveBackpackData(plr, ds)
	end
	Signals.ItemsAdded:Connect(saveData)
	Signals.ItemsEquipped:Connect(saveData)
	Signals.ItemsPinned:Connect(saveData)
end

--[[
	Actions when player left, save the data, and clear the existence of world
]]
function PlayerSetups:Clear(plr: Player)
	local ds = self:FindDataStore(plr)

	if ds then
		self:SaveBackpackData(plr, ds)
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
end

return function ()
    local self = setmetatable({}, PlayerSetups)

    self.TEMPLATE = {
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
	self.DS1, self.DS2, self.DS3 = "CSTORY_BETA_1599", "CSTORY_BETA_1599_S2", "CSTORY_BETA_1599_S3"

	--// Connections
	local function _playerAdded(plr: Player)
		if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
			self:Setup(plr)
		end
	end
	local function _playerLeft(plr: Player)
		self:Clear(plr)
	end
	Players.PlayerAdded:Connect(_playerAdded)
	Players.PlayerRemoving:Connect(_playerLeft)

	--- in case player joined before server starts
	for _, plr in Players:GetPlayers() do
		FastSpawn(function()
			self:Setup(plr)
		end)
	end
end