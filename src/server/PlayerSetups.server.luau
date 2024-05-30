--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ItemBook = require(ReplicatedStorage.Modules.Data.ItemBook)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local ProfileService = require(ServerScriptService.Modules.Packages.ProfileService)
local StoryBook = require(ReplicatedStorage.Modules.Data.StoryBook)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)
local Signals = require(ServerScriptService.Modules.Data.ServerSignals)

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
	profiles[plr].Data[slot].QuestsV3 = quests
end


local function setup(plr: Player)
	local newDS = ProfileService.GetProfileStore("CS_1599MKK", TEMPLATE)
	local profile = newDS:LoadProfileAsync("Player_"..plr.UserId)

	if profile ~= nil then
		profile:AddUserId(plr.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			profiles[plr] = nil

			plr:Kick("Data has already loaded on another server!")
		end)

		if plr:IsDescendantOf(Players) then
			profiles[plr] = profile

			local slot = _getSlot(plr)
			local Add, Empty = HarukaLib.Bin()
			scopes[plr] = Empty

			local data = profile.Data[slot]

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
			for questType: string, questId: number in data.QuestsV3 do
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

			--// Finish
			plr:SetAttribute("LastSeenWorld", workspace:GetAttribute("WorldType") or "Mainworld")
			plr:SetAttribute("PlayerDataLoaded", true)

			--// Check if banned
			task.wait(5)
			local banInfo = profile.Data[slot].BanStats :: table
			if banInfo.EndTime - os.time() > 0 then
				local timeLeft = (banInfo.EndTime - os.time()) / 60 / 60

				plr:Kick("You got banned! Reason: "..banInfo.Reason..", unban in "..HarukaLib:NumberConvert(timeLeft).." hours!")
			end
		else
			profile:Release()
		end
	else
		plr:Kick("Data has already loaded on another server!")
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

	pcall(_saveData, plr)
	if scopes[plr] then scopes[plr]() end
	if profiles[plr] then profiles[plr]:Release() end

	scopes[plr] = nil
end

--- in case player joined before server starts
for _, plr in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)


local function banRequest(plr: Player, duration: number, reason: string)
	local profile = profiles[plr]
	if not profile then return end

	local slot = _getSlot(plr)
	local banInfo = {
		Duration = os.time() + (duration * 60 * 60),
		Reason = reason
	}

	profile.Data[slot].BanStats = banInfo
end
Signals.BanRequest:Connect(banRequest)
