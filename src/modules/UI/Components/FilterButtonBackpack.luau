--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Computed, peek = Fusion.Computed, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait = task.wait
local tFind = table.find
local sFind, upper = string.find, string.upper

local function _checkSlot(self: table, type: string) : string
	local classFrame = self.plrGui.AdventurerStats.Bottom.ClassFrame

	for _, element: Frame in classFrame:GetDescendants() do
		if sFind(element.Name, type) and not element:GetAttribute("Equipped") then
			return element.Name
		end
	end

	return "Full"
end
local function _checkSameItem(self: table, item: string, type: string) : (string, string?)
	local classFrame = self.plrGui.AdventurerStats.Bottom.ClassFrame

	local check, sameSlot = false, nil
	for _, element: Frame in classFrame:GetDescendants() do
		if sFind(element.Name, type) and element:GetAttribute("ItemEquipped") == item then
			check = true
			sameSlot = element.Name
		end
	end

	return if not check then "None" else "Exist", sameSlot
end
local function _findItem(itemFrame: Frame) : string
	local item: string?
	for _, child: ImageButton in itemFrame:GetChildren() do
		if child:IsA("ImageButton") and child:GetAttribute("Selected") then item = child.Name end
	end
	if not item then return "None" end

	return item
end

--- note: from v0.7, server will just open a new thread for equipping
--- because of this, checks may not work, so we need to do it in client first
local function _checkEquippedItems(self: table, requestItem: string) : boolean
	local itemInfo = ItemBook:FindItem(requestItem)
	if itemInfo.ItemId == nil then return false end

	local count = 0
	local maxCount = 3
	local check = true

	for _, item: IntConstrainedValue in self.plr.Inventory:GetChildren() do
		if item:GetAttribute("Equipped") and ItemBook:FindItem(item.Name).Type == itemInfo.Type then count += 1 end
	end
	if count >= maxCount and not self.plr.Inventory[requestItem]:GetAttribute("Equipped") then check = false end

	return check
end

local function FilterButtonBackpack(id: string, self: table): TextButton
	local scope = self.scope :: Fusion.Scope
	local COLORS = {
		Passive = fromRGB(40, 98, 3),
		Active = fromRGB(167, 111, 83),
		Material = fromRGB(0, 130, 139),
		Equipment = Color3.fromHex('#7b1fa2'),
		Other = fromRGB(0, 130, 139),

		Equip = fromRGB(131, 131, 65),
		Pin = fromRGB(93, 47, 140),
	}
	local BLACKLIST = { "Equip", "Pin" }

	return Components.TextButton(scope, {
		Name = id,
		BackgroundColor3 = COLORS[id],

		Text = Computed(scope, function(use: Fusion.Use)
			return if tFind(BLACKLIST, id) then use(self.filterInfo[id]) else upper(id)
		end),
		Size = fromScale(0.125, 1),

		[Fusion.Children] = {
			Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
					return if use(self.chosenFilter) == id and not tFind(BLACKLIST, id) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			if peek(self.chosenFilter) == id then return end

			if id == "Equip" or id == "Pin" then
				if self.equipClickCD then return end

				self.equipClickCD = true

				Spawn(function()
					wait(0.3)
					self.equipClickCD = false
				end)
			end

			if id == "Equip" then
				local item = _findItem(peek(self.itemFrame))

				if item == "None" then return end

				local itemInfo = ItemBook:FindItem(item)
				local itemType = itemInfo.Type :: string
				if not itemType then return end

				--- equip
				local whiteList = { "Active", "Passive", "Cosmetic" }
				if not tFind(whiteList, itemType) then
					Signals.CreateHint:Fire(`You can't equip {itemType}!`)
					return
				end

				if itemType == "Cosmetic" then
					local currentCos = self.plr:GetAttribute("Cosmetic") :: string
					if not currentCos or currentCos == "None" then
						Events.EquipItem.Fire({ ItemType = "Cosmetic", ItemSlot = "Cosmetic1", ItemId = item })
					else
						Events.EquipItem.Fire({ ItemType = "ClearCosmetic", ItemSlot = "Cosmetic1", ItemId = item })
					end
					return
				end

				local slot = _checkSlot(self, itemType)
				local checkSame, sameSlot = _checkSameItem(self, item, itemType)

				if slot == "Full" and checkSame == "None" then Signals.CreateHint:Fire("Not enough space to equip!") return end
				if slot ~= "Full" and checkSame == "None" then
					--- check first
					local equipCheck = _checkEquippedItems(self, item)
					if not equipCheck then Signals.CreateHint:Fire("Not enough space to equip this item!") return end

					-- local assign first, to fix equip bug when server lag while equiping
					self.inventory[item]:SetAttribute("Equipped", true)
					self.inventory[item]:SetAttribute("Slot", slot)

					Events.EquipItem.Fire({ ItemType = itemType, ItemSlot = slot, ItemId = item })

				elseif checkSame == "Exist" then
					Events.EquipItem.Fire({ ItemType = "Clear"..itemType, ItemSlot = sameSlot, ItemId = item })
				end

			elseif id == "Pin" then
				local item = _findItem(peek(self.itemFrame))
				if item == "None" then return end

				Events.UpdatePinnedItem.Fire({ ItemId = item })

			else
				self.chosenFilter:set(id)
				self.items:set(self.inventory:GetChildren())

				self:DeselectAll()
			end
		end,
	})
end

return FilterButtonBackpack
