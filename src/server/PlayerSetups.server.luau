--!nocheck

local BadgeService = game:GetService("BadgeService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClassBook = require(RepS.Modules.Data.ClassBook)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local ProfileService = require(RepS.Modules.Packages.ProfileService)
local RankBook = require(RepS.Modules.Data.RankBook)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local profiles = {}
local scopes = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)
local EXTRA_TEMPLATE = require(SSS.Modules.Data.ExtraPlayerTemplate)

local profileStore = ProfileService.GetProfileStore("CS_1599MKK", TEMPLATE)

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
	profiles[plr].Data[slot].QuestsV3 = quests
end

local function setup(plr: Player)
	Promise.new(function(resolve, reject)
		local profile = profileStore:LoadProfileAsync("Player_"..plr.UserId)

		if profile then resolve(profile) else reject("Profile is nil") end

	end):andThen(function(profile)
		profile:Reconcile()
		profile:AddUserId(plr.UserId)

		profile:ListenToRelease(function()
			profiles[plr] = nil
			plr:Kick("Data was loaded on another roblox server, please try again later?")
		end)

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

		--// Load donations
		plr:SetAttribute("Donation", data.Donation)
		Add(HarukaLib:Hydrate(plr, {
			["Attr-Donation"] = function(newVal: number)
				profile.Data[slot].Donation = newVal
			end
		}))

		--// Load quests
		local function _createQuestVal(questType: string, val: number)
			local intValue = Instance.new("IntConstrainedValue")
			intValue.Name = questType
			intValue.MinValue = 1
			intValue.MaxValue = #StoryBook[questType]
			intValue.Value = val
			intValue.Parent = questsData
		end
		for questType: string, questId: number in data.QuestsV3 do
			if StoryBook[questType][questId] == nil then continue end

			if questType == "Town" or questType == "Side" then
				for _, separateQuest: number in questId do
					for _, quest: IntConstrainedValue in questsData:GetChildren() do
						if quest.Name == questType and quest.Value == separateQuest then quest:Destroy() end
					end

					_createQuestVal(questType, separateQuest)
				end
				continue
			end

			_createQuestVal(questType, questId)
		end

		--// Load items
		for index: string, info: table in data.Inventory do
			if not ItemBook:IsItemExist(index) then continue end
			if backpackData:FindFirstChild(index) then continue end --- fix dupe

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
		plr:SetAttribute("CLASS_UNLOCK_"..data.Stats.Class, true)

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

		--// Check if user own past gamepasses from legacy
		Spawn(function()
			local gamepassIds = AssetBook.GamepassInfo

			for gamepassId: string, state: boolean in data.GamepassOwned do
				plr:SetAttribute("GAMEPASS_"..gamepassId, state)
			end

			for gamepassId: number, donationVal: number in gamepassIds do
				if plr:GetAttribute("GAMEPASS_"..gamepassId) then continue end

				if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId) then
					profile.Data[slot].GamepassOwned[tostring(gamepassId)] = true
					profile.Data[slot].Donation += donationVal

					plr:SetAttribute("GAMEPASS_"..gamepassId, true)
					HarukaLib:AddAttr(plr, "Donation", donationVal)
				end
			end
		end)

	end):catch(function(msg)
		plr:Kick("Your data failed to load, please try again later?")

		warn(`[DATA LOAD]: {msg}`)
	end)

	--// Assign role
	Spawn(function()
		ServerUtil:SetRole(plr)
	end)

	--// apply all old badges: V0.9
	Spawn(function()
		if true then return end

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


--// Marketplace developer products
local function _purchaseCheckAsync(profile: table, purchaseId: number, productCallback: () -> ()) : Enum.ProductPurchaseDecision
	if profile:IsActive() ~= true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		local metaData = profile.MetaData :: table

		local purchaseIds = metaData.MetaTags.ProfilePurchaseIds
		if purchaseIds == nil then
			purchaseIds = {}

			metaData.MetaTags.ProfilePurchaseIds = purchaseIds
		end

		--- granting product
		if table.find(purchaseIds, purchaseId) == nil then
			while #purchaseIds >= 50 do
				table.remove(purchaseIds, 1)
			end

			table.insert(purchaseIds, purchaseId)
			task.spawn(productCallback)
		end

		--- waiting until purchase is confirmed
		local result = nil
		local function _checkLatestMetaTags()
			local savedPurchaseIds = metaData.MetaTagsLatest.ProfilePurchaseIds
			if savedPurchaseIds ~= nil and table.find(savedPurchaseIds, purchaseId) ~= nil then
				result = Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end

		_checkLatestMetaTags()
		local metaTagsConnection = profile.MetaTagsUpdated:Connect(function()
			_checkLatestMetaTags()

			--- when it's fired after profile release
			if profile:IsActive() == false and result == nil then
				result = Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end) :: RBXScriptConnection

		while result == nil do
			task.wait()
		end

		metaTagsConnection:Disconnect()

		return result
	end
end
local function _getPlayerProfileAsync(plr: Player) : table | nil
	local profile = profiles[plr]

	while profile == nil and plr:IsDescendantOf(Players) do
		task.wait()
		profile = profiles[plr]
	end

	return profile
end
local function _grantProduct(plr: Player, productId: number)
	local profile = profiles[plr]
	local productCallback = EXTRA_TEMPLATE.Products[productId]

	if productCallback == nil then
		warn("Product Id: "..productId.." has not defined yet.")
	else
		productCallback(profile, plr)
	end
end
local function processReceipt(receiptInfo: table)
	local plr = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if plr == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = _getPlayerProfileAsync(plr)
	if profile == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return _purchaseCheckAsync(profile, receiptInfo.PurchaseId, function()
		_grantProduct(plr, receiptInfo.ProductId)
	end)
end
MarketplaceService.ProcessReceipt = processReceipt


MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr: Player, gamepassId: number, success: boolean)
	if success and plr:IsDescendantOf(Players) then
		if gamepassId == 881563847 then HarukaLib:AddAttr(plr, "Donation", 139) end --- private server
		if gamepassId == 881445935 then HarukaLib:AddAttr(plr, "Donation", 99) end --- valkyrie armor
	end
end)
