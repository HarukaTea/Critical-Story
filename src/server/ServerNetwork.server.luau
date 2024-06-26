--!nocheck

local Debris = game:GetService("Debris")
local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local TeleS = game:GetService("TeleportService")
local TestS = game:GetService("TestService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local DialogueBook = require(RepS.Modules.Data.DialogueBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local RecipeBook = require(RepS.Modules.Data.RecipeBook)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local PassiveUtil = require(SSS.Modules.Utils.PassiveUtil)

local floor = math.floor
local fromRGB = Color3.fromRGB
local wait = task.wait
local instanceNew = Instance.new
local sFind, sub = string.find, string.sub


local function promptsHandler(prompt: ProximityPrompt, plr: Player)
	if prompt.Name == "Class" then
		local class = prompt.Parent.Parent.Name

		plr:SetAttribute("Class", class)

	elseif prompt.Name == "Chest" then
		local chest = prompt.Parent.Parent :: Model

		chest:SetAttribute(plr.Name, true)

		Events.ChestUnlocked:Fire(plr, chest)

		ServerUtil:GiveItem(plr, chest.Name, chest:GetAttribute("Amount") or 1)

	elseif prompt.Name == "Chat" then
		local npc = prompt.Parent.Parent :: Model

		Events.NPCChat:Fire(plr, npc, prompt)

	elseif prompt.Name == "Shop" then
		local shop = prompt.Parent.Parent :: Model
		local items = {}

		for _, item: Instance in shop.SellingItems:GetChildren() do
			items[#items + 1] = item.Name
		end

		plr:SetAttribute("CurrentShop", shop.Name)

		Events.EnterShopping:Fire(plr, items)

	elseif prompt.Name == "Travel" then
		local world = prompt:GetAttribute("Destination") :: string
		local worldId = AssetBook.WorldInfo[world]

		if prompt:GetAttribute("Require") then
			if not plr.Inventory:FindFirstChild(prompt:GetAttribute("Require")) then
				Events.CreateHint:Fire(plr, "You don't have a ticket!")
				return
			end
		end
		local joinData = plr:GetJoinData().TeleportData :: table?
		local slotChosen = if joinData then joinData[1] else "Slot1"

		local teleportOptions = instanceNew("TeleportOptions")
		teleportOptions:SetTeleportData({ slotChosen })
		TeleS:TeleportAsync(worldId, { plr }, teleportOptions)

	elseif prompt.Name == "Material" then
		local hasTool = false
		if prompt:GetAttribute("Special") then
			local essential = prompt:GetAttribute("Special") :: string

			if plr.Character:GetAttribute(essential) then hasTool = true end
		else
			hasTool = true
		end

		if not hasTool then return end
		if plr:GetAttribute("MaterialCD") then return end

		plr:SetAttribute("MaterialCD", true)
		Spawn(function()
			wait(1)
			if plr then plr:SetAttribute("MaterialCD", nil) end
		end)

		prompt.Enabled = false

		local material = prompt.Parent.Parent :: Model
		local finalMaterial = material.Name
		if prompt:GetAttribute("Rare") then
			finalMaterial = HarukaLib:RollLoot({
				[prompt:GetAttribute("Rare")] = 85,
				[material.Name] = 15
			})
		end

		material.Parent = TestS

		ServerUtil:GiveItem(plr, finalMaterial, #material.Items:GetChildren())

		wait(120)
		material.Parent = workspace.MapComponents.Materials
		prompt.Enabled = true
	end
end
PPS.PromptTriggered:Connect(promptsHandler)


local LEVEL_CAP = 1100
local LEVEL_POINT = 2
local function _expCheck(exp: number, level: number) : boolean
	return if exp >= floor(level ^ 1.65) + 59 and level < LEVEL_CAP then true else false
end
local function levelUp(plr: Player)
	local check = _expCheck(plr:GetAttribute("EXP"), plr:GetAttribute("Levels"))

	if check then
		HarukaLib:AddAttr(plr, "EXP", -(floor(plr:GetAttribute("Levels") ^ 1.65) + 59))
		HarukaLib:AddAttr(plr, "Levels", 1)
		HarukaLib:AddAttr(plr, "LvPoints", LEVEL_POINT)

		if _expCheck(plr:GetAttribute("EXP"), plr:GetAttribute("Levels")) then levelUp(plr) return end

		local char = plr.Character :: Model

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.LevelUp)
		Events.LevelUp:Fire(plr)

		ServerUtil:ShowText(char, "LEVEL UP!", fromRGB(255, 255, 0))

		local levelUpEffect = RepS.Package.Effects.LevelUpEffect:Clone() :: ParticleEmitter
		levelUpEffect.Parent = char.PrimaryPart
		Debris:AddItem(levelUpEffect, 1)

		--- make character full state
		char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
		char.Humanoid.Health = char.Humanoid.MaxHealth
	end
end
Signals.LevelUp:Connect(levelUp)


local function addPoint(plr: Player, option: string, times: number)
	if option == "Reset" then
		local level = plr:GetAttribute("Levels")
		local cost = ((level - 1) * LEVEL_POINT - plr:GetAttribute("LvPoints")) * 20

		if plr:GetAttribute("Gold") < cost then
			Events.CreateHint:Fire(plr, "You don't have enough Gold to reset!")
			return
		end

		HarukaLib:AddAttr(plr, "Gold", -cost)
		plr:SetAttribute("DMGPoints", 0)
		plr:SetAttribute("MagicPoints", 0)
		plr:SetAttribute("HealthPoints", 0)
		plr:SetAttribute("ShieldPoints", 0)
		plr:SetAttribute("ManaPoints", 0)
		plr:SetAttribute("LvPoints", (level - 1) * LEVEL_POINT)
		return
	end

	--// Add points
	for _ = 1, times do
		if plr:GetAttribute("LvPoints") > 0 then
			HarukaLib:AddAttr(plr, option, 1)
			HarukaLib:AddAttr(plr, "LvPoints", -1)
		end
	end
end
Events.AddPoints:Connect(addPoint)


local function _equipCheck(plr: Player, itemType: string, requestItem: string) : boolean
	local count = 0
	local check = true
	for _, item: IntConstrainedValue in plr.Inventory:GetChildren() do
		if item:GetAttribute("Equipped") and ItemBook:FindItem(item.Name).Type == itemType then count += 1 end
	end
	if count >= 3 and not plr.Inventory[requestItem]:GetAttribute("Equipped") then check = false end

	return check
end
local function _equipNewItem(plr: Player, item: string, slot: string)
	local inventory = plr.Inventory :: Folder

	if not inventory:FindFirstChild(item) then return end
	if inventory[item]:GetAttribute("Equipped") then return end

	inventory[item]:SetAttribute("Equipped", true)
	inventory[item]:SetAttribute("Slot", slot)

	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Equip)
end
local function _unequipCheck(plr: Player, item: string)
	local inventory = plr.Inventory :: Folder

	if inventory:FindFirstChild(item) then
		inventory[item]:SetAttribute("Equipped", nil)
		inventory[item]:SetAttribute("Slot", nil)
	end
end
local function equipItem(plr: Player, itemType: string, itemSlot: string, item: string)
	local char = plr.Character

	if itemType == "Passive" then
		if not char.CharStats.Items:GetAttribute(item) then PassiveUtil:EquipPassive(item, char) end
		if not _equipCheck(plr, itemType, item) then return end

		_equipNewItem(plr, item, itemSlot)

		Events.EquipItems:Fire(plr, itemSlot, item)

	elseif itemType == "Active" then
		if not _equipCheck(plr, itemType, item) then return end

		_equipNewItem(plr, item, itemSlot)

		Events.EquipItems:Fire(plr, itemSlot, item)

	elseif itemType == "Cosmetic" then
		plr:SetAttribute("Cosmetic", item)

		_equipNewItem(plr, item, itemSlot)

		ServerUtil:EquipArmor(plr.Character, item)

	elseif itemType == "ClearPassive" and item ~= "" then
		PassiveUtil:UnequipPassive(char, item)

		_unequipCheck(plr, item)

		Events.EquipItems:Fire(plr, itemSlot, "Null")

	elseif itemType == "ClearActive" and item ~= "" then
		_unequipCheck(plr, item)

		Events.EquipItems:Fire(plr, itemSlot, "Null")

	elseif itemType == "ClearCosmetic" then
		_unequipCheck(plr, item)

		plr:SetAttribute("Cosmetic", "None")

		ServerUtil:EquipArmor(char, nil)
	end
end
Events.EquipItems:Connect(equipItem)


local function buyItems(plr: Player, item: string, amount: number)
	local cost = ItemBook:FindItem(item).Price * amount
	local currentShop = plr:GetAttribute("CurrentShop") :: string

	if not currentShop then
		Events.CreateHint:Fire(plr, "You aren't in the shop!")
		return
	else
		local shopModel = workspace.MapComponents.WorldShops:FindFirstChild(currentShop, true)
		local distance = plr:DistanceFromCharacter(shopModel.Prompt.Position)

		if distance >= 25 or distance <= 0 then
			Events.CreateHint:Fire(plr, "You're far away from the shop!")
			return
		end
	end
	if plr:GetAttribute("Gold") < cost then
		Events.CreateHint:Fire(plr, "You don't have enough Gold to buy this item!")
		return
	end

	HarukaLib:AddAttr(plr, "Gold", -cost)

	ServerUtil:GiveItem(plr, item, amount)
end
Events.BuyItems:Connect(buyItems)


local function _essentialCheck(plr: Player, item: string) : string
	return if plr.Inventory:FindFirstChild(item) and plr.Inventory[item].Value > 0 then true else false
end
local function useItem(plr: Player, item: string)
	if SS.Resources.Items.Active:FindFirstChild(item) and _essentialCheck(plr, item) then
		if plr.Character.CharStats.Items:FindFirstChild(item) then
			Events.CreateHint:Fire(plr, "Still in cooldown, please wait!")
			return
		end

		SS.Resources.Items.Active[item]:Clone().Parent = plr.Character.CharStats.Items
	end
end
Events.UseItem:Connect(useItem)


local function pinItem(plr: Player, item: string)
	if not plr.Inventory:FindFirstChild(item) then return end

	local realItem = plr.Inventory[item] :: IntConstrainedValue
	realItem:SetAttribute("Pinned", if realItem:GetAttribute("Pinned") then nil else true)
end
Events.UpdatePinnedItems:Connect(pinItem)


local function npcChatEnded(plr: Player, npc: Model, series: string)
	-- checks
	if not npc then return end
	if not StoryBook[series] then return end
	if not plr.Quests:FindFirstChild(series) then return end

	if series == "Town" then
		local currentId: number = nil

		for _, quest in plr.Quests:GetChildren() do
			if quest.Name ~= "Town" then continue end
			if StoryBook[series][quest.Value].NPC == npc.Name
				and not plr.Character.CharStats.Quests:FindFirstChild(series..quest.Value) then

				currentId = quest.Value
			end
		end
		if currentId == nil then return end

		ServerUtil:GiveQuestRewards(series, currentId, plr)

		for _, quest in plr.Quests:GetChildren() do
			if quest.Name == "Town" and quest.Value == currentId then quest:Destroy() end
		end

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

		if DialogueBook[npc.Name].Extra[series..currentId] then
			Signals[DialogueBook[npc.Name].Extra[series..currentId]]:Fire(plr)
		end

	else
		local currentId = plr.Quests[series].Value :: number
		if StoryBook[series][currentId].NPC ~= npc.Name then return end

		if DialogueBook[npc.Name].Extra[series..currentId] then
			Signals[DialogueBook[npc.Name].Extra[series..currentId]]:Fire(plr)
			return
		end

		ServerUtil:GiveQuestRewards(series, currentId, plr)

		plr.Quests[series]:Destroy()

		local quest = instanceNew("IntConstrainedValue")
		quest.Name = series
		quest.MinValue = 1
		quest.MaxValue = #StoryBook[series]
		quest.Value = currentId + 1
		quest.Parent = plr.Quests

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)
	end
end
Events.NPCChatEnded:Connect(npcChatEnded)


local function _newQuest(series: string, questId: number, plr: Player)
	local newQuest = instanceNew("IntConstrainedValue")
	newQuest.Name = series
	newQuest.MinValue = 1
	newQuest.MaxValue = #StoryBook[series]
	newQuest.Value = questId + 1
	newQuest.Parent = plr.Quests
end
local function questCompleted(series: string, questId: number, plr: Player, needNewQuest: boolean)
	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

	ServerUtil:GiveQuestRewards(series, questId, plr)

	for _, quest: IntConstrainedValue in plr.Quests:GetChildren() do
		if quest.Name == series and quest.Value == questId then quest:Destroy() end
	end
	if needNewQuest then _newQuest(series, questId, plr) end
end
Signals.QuestComplete:Connect(questCompleted)


local function newQuest(plr: Player, npc: Model, series: string, questId: number)
	if StoryBook[series][questId].NPC ~= npc.Name then return end

	local quest = instanceNew("IntConstrainedValue")
	quest.Name = series
	quest.MinValue = 1
	quest.MaxValue = #StoryBook[series]
	quest.Value = questId
	quest.Parent = plr.Quests
end
Events.NewQuest:Connect(newQuest)


local function changeLastSeen(plr: Player, location: string)
	plr:SetAttribute("LastSeenLocation", location)
	plr:SetAttribute("RespawnLocation", workspace.Maps[location].SpawnPoint.Position)
end
Events.ChangePlayerLocation:Connect(changeLastSeen)


local function toggleSettings(plr: Player, id: string)
	if sFind(id, "Combat") then
		local mode = sub(id, 1, sFind(id, "Combat") - 1)

		if plr:GetAttribute("CombatMode") == mode then
			plr:SetAttribute("CombatMode", "Solo")
			return
		end

		plr:SetAttribute("CombatMode", mode)
		return
	end

	plr:SetAttribute(id, not plr:GetAttribute(id))
end
Events.ChangePlayerSetting:Connect(toggleSettings)


local function switchMobTarget(plr: Player, monster: Model)
	if monster:HasTag("Monster") and monster:GetAttribute("Health") > 0 and monster.PrimaryPart then
		plr.Character.CharStats.TargetMonster.Value = monster
	end
end
Events.ChangeMobTarget:Connect(switchMobTarget)


local function rejoinRequest(plr: Player)
	TeleS:Teleport(game.PlaceId, plr)
end
Events.RejoinRequest:Connect(rejoinRequest)


local function forceReset(plr: Player)
	plr.Character.Humanoid.Health = 0
end
Events.ForceReset:Connect(forceReset)
