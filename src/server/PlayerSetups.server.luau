--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ClassBook = require(RepS.Modules.Data.ClassBook)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local ProfileService = require(RepS.Modules.Packages.ProfileService)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local profiles = {}
local scopes = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local EXTRA_TEMPLATE = require(SSS.Modules.Data.ExtraPlayerTemplate)

local profileStore = ProfileService.GetProfileStore("CS_1599MKK40_VCA_TEST", TEMPLATE)

--// Private

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

local function setup(plr: Player)
	Promise.new(function(resolve, reject)
		local profile = profileStore:LoadProfileAsync("Player_"..plr.UserId)

		if profile then resolve(profile) else reject("Profile is nil") end

	end):andThen(function(profile)
		profile:Reconcile()
		profile:AddUserId(plr.UserId)

		if not plr:IsDescendantOf(Players) then
			profile:Release()
			return
		end

		profiles[plr] = profile
		print("Loaded data for player: "..plr.UserId)

		local slot = _getSlot(plr)
		local data = profile.Data[slot] :: table

		local Add, Empty = HarukaLib.Bin()
		scopes[plr] = Empty

		local backpackData = Instance.new("Folder")
		backpackData.Name = "Inventory"
		backpackData.Parent = plr

		local questsData = Instance.new("Folder")
		questsData.Name = "Quests"
		questsData.Parent = plr

		---// Load stats
		for attr: string, val: any in data.Stats do
			plr:SetAttribute(attr, HarukaLib:Deserialize(val))

			Add(HarukaLib:Hydrate(plr, {
				["Attr-"..attr] = function(newStats: any)
					if newStats == nil then return end --// We have false boolean data

					profile.Data[slot].Stats[attr] = HarukaLib:Serialize(newStats)
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
		for setting: string, value: any in EXTRA_TEMPLATE.Settings do
			plr:SetAttribute(setting, value)
		end

		--// Load unlockables
		for unlockedClass: string, state: boolean in data.ClassUnlocks do
			if not state then continue end

			plr:SetAttribute("CLASS_UNLOCK_"..unlockedClass, true)
		end
		local classUnlocksListener = {}
		for class: string, _ in ClassBook.ClassInfo do
			classUnlocksListener["Attr-CLASS_UNLOCK_"..class] = function(state: boolean)
				if not state then return end

				profile.Data[slot].ClassUnlocks[class] = true
			end
		end
		Add(HarukaLib:Hydrate(plr, classUnlocksListener))

		--// Unlock worlds
		local currentWorld = workspace:GetAttribute("WorldType") or "Mainworld"
		profile.Data[slot].WorldUnlocks[currentWorld] = true


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

		--// Assign role
		Spawn(function()
			local rank = plr:GetRankInGroup(16912246)
			plr:SetAttribute("Rank", rank)
		end)

		--// Finish
		plr:SetAttribute("LastSeenWorld", currentWorld)
		plr:SetAttribute("PlayerDataLoaded", true)

	end):catch(function(msg)
		plr:Kick("Your data failed to load, please try again later?")

		warn(`[DATA LOAD]: {msg}`)
	end)

	--// Check if player has alpha tester badge (from legacy)
	ServerUtil:GiveBadge({ 783240039527287, 2129794607 }, plr)

	--// Award welcome! badge
	ServerUtil:GiveBadge({ 2362555015922939 }, plr)

	--// Former savior badge
	ServerUtil:GiveBadge({ 3950161757254227, 2132605760 }, plr)

	--// Hardmode wolf badge
	ServerUtil:GiveBadge({ 2212542348620168, 3730879662265300 }, plr)

	--// Crimson Slime badge
	ServerUtil:GiveBadge({ 2422984775435251, 3235712599678594 }, plr)

	--// Check if it's founder Milk
	Spawn(function()
		if plr.UserId == 304008764 then
			for _, player: Player in Players:GetPlayers() do
				--// Met the owner badge
				ServerUtil:GiveBadge({ 3537691008965081 }, player)
			end
		end

		--- when a new player joins, give TA the owner badge
		for _, player: Player in Players:GetPlayers() do
			if player.UserId == 304008764 then
				--// Met the owner badge
				ServerUtil:GiveBadge({ 3537691008965081 }, plr)
				break
			end
		end
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
end

for _, plr in Players:GetPlayers() do
	Spawn(setup, plr)
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)
