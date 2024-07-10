--!nocheck

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataKeep = require(ReplicatedStorage.Modules.Packages.DataKeep)
local ItemBook = require(ReplicatedStorage.Modules.Data.ItemBook)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local StoryBook = require(ReplicatedStorage.Modules.Data.StoryBook)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local profiles = {}
local scopes = {}

local TEMPLATE = require(ServerScriptService.Modules.Data.PlayerTemplate)

local function _getSlot(plr: Player) : "Slot1" | "Slot2" | "Slot3"
	local joinData = plr:GetJoinData().TeleportData :: table?
	local slotChosen = if joinData then joinData[1] else "Slot1"

	return slotChosen
end

local function _saveData(plr: Player)
	local inventory = {}
	local quests, townQuests, sideQuests = {}, {}, {}

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

		elseif quest.Name == "Side" then
			sideQuests[#sideQuests + 1] = quest.Value
		else
			quests[quest.Name] = quest.Value
		end
	end
	quests.Side = sideQuests
	quests.Town = townQuests

	local slot = _getSlot(plr)

	profiles[plr].Data[slot].Inventory = inventory
	profiles[plr].Data[slot].Quests = quests
end

local dataKeepStore = DataKeep.GetStore("CS_1599MKK40", TEMPLATE)

local function setup(plr: Player)
	dataKeepStore:LoadKeep("Player_"..plr.UserId):andThen(function(keep)
		if keep == nil then
			plr:Kick("Data loaded failed! This is a rare error, please try again later.")
		end

		keep:Reconcile()
		keep:AddUserId(plr.UserId)

		keep.Releasing:Connect(function(state)
			state:andThen(function()
				plr:Kick("Your session has been released, maybe rejoin later?")
			end)
		end)

		if not plr:IsDescendantOf(Players) then
			keep:Release()
			return
		end

		profiles[plr] = keep

		local slot = _getSlot(plr)
		local Add, Empty = HarukaLib.Bin()
		scopes[plr] = Empty

		local data = keep.Data[slot]

		local backpackData = Instance.new("Folder")
		backpackData.Name = "Inventory"
		backpackData.Parent = plr

		local questsData = Instance.new("Folder")
		questsData.Name = "Quests"
		questsData.Parent = plr

		---// Load stats
		local blackList = { "V9Transfered", "RespawnLocation" }
		for attr: string, val: any in data.Stats do
			if table.find(blackList, attr) then continue end

			plr:SetAttribute(attr, HarukaLib:Deserialize(val))

			Add(HarukaLib:Hydrate(plr, {
				["Attr-"..attr] = function(newStats: any)
					if newStats == nil then return end --// We have false boolean data

					keep.Data[slot].Stats[attr] = HarukaLib:Serialize(newStats)
				end
			}))
		end

		--// Load quests
		local function _createQuestVal(questType: string, val: number)
			local intValue = Instance.new("IntConstrainedValue")
			intValue.Name = questType
			intValue.MinValue = 1
			intValue.MaxValue = #StoryBook[questType]
			intValue.Value = val
			intValue.Parent = questsData
		end
		for questType: string, questId: number in data.Quests do
			if questType == "Town" or questType == "Side" then
				for _, separateQuest: number in questId do _createQuestVal(questType, separateQuest) end
				continue
			end

			_createQuestVal(questType, questId)
		end

		--// Load items
		for index: string, info: table in data.Inventory do
			if not ItemBook:IsItemExist(index) then continue end

			local itemType = ItemBook:FindItem(index).Type
			local maxAmount = 1

			if itemType == "Active" then if not ItemBook:FindItem(index).IsSkill then maxAmount = 999 end end
			if itemType == "Material" then maxAmount = 999 end

			local intValue = Instance.new("IntConstrainedValue")
			intValue.Name = index
			intValue.MaxValue = maxAmount
			intValue.Value = info.Amount
			if info.Equipped then
				intValue:SetAttribute("Equipped", true)
				intValue:SetAttribute("Slot", info.Slot)
			end
			if info.Pinned then intValue:SetAttribute("Pinned", true) end
			intValue.Parent = backpackData
		end

		--// Load settings
		for setting: string, val: any in TEMPLATE.Slot1.Settings do plr:SetAttribute(setting, val) end

		--// Connections
		local function _save()
			task.wait()
			_saveData(plr)
		end
		Add(backpackData.ChildAdded:Connect(_save))
		Add(backpackData.ChildRemoved:Connect(_save))
		Add(questsData.ChildAdded:Connect(_save))
		Add(questsData.ChildRemoved:Connect(_save))

		--// Play time
		Add(HarukaLib.Clock(1, function()
			HarukaLib:AddAttr(plr, "PlayTime", 1)
		end))

		--// Finish
		plr:SetAttribute("LastSeenWorld", workspace:GetAttribute("WorldType") or "Mainworld")
		plr:SetAttribute("PlayerDataLoaded", true)


		--// Check if player has alpha tester badge (from legacy)
		Spawn(function()
			Promise.new(function()
				local hasBadgeOld = BadgeService:UserHasBadgeAsync(plr.UserId, 2129794607)
				local hasBadgeNow = BadgeService:UserHasBadgeAsync(plr.UserId, 783240039527287)

				if hasBadgeOld and not hasBadgeNow then BadgeService:AwardBadge(plr.UserId, 783240039527287) end

			end)
		end)
	end)
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

	pcall(_saveData, plr)
	if scopes[plr] then scopes[plr]() end
	if profiles[plr] then profiles[plr]:Release() end

	scopes[plr] = nil
	profiles[plr] = nil
end
Players.PlayerRemoving:Connect(clear)


--- in case player joined before server starts
dataKeepStore:andThen(function(store)
	dataKeepStore = store

	for _, player: Player in Players:GetPlayers() do
		Spawn(setup, player)
	end

	Players.PlayerAdded:Connect(setup)
end)
