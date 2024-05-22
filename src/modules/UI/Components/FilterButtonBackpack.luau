--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)

local Computed, peek = Fusion.Computed, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait = task.wait
local tFind = table.find
local sFind, upper = string.find, string.upper

local COLORS = {
	Passive = fromRGB(40, 98, 3),
	Active = fromRGB(167, 111, 83),
	Other = fromRGB(0, 130, 139),

	Equip = fromRGB(131, 131, 65),
	Use = fromRGB(103, 154, 154),
	Pin = fromRGB(93, 47, 140),
}
local BLACKLIST = { "Equip", "Pin", "Use" }

local function _checkSlot(self: table, type: string) : string
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

	for _, element: Frame in classFrame:GetDescendants() do
		if sFind(element.Name, type) and not element:GetAttribute("Equipped") then
			return element.Name
		end
	end

	return "Full"
end
local function _checkSameItem(self: table, item: string, type: string) : (string, string?)
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

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

local function FilterButtonBackpack(id: string, self: table): TextButton
	local scope = self.scope

	return Components.TextButton(scope, {
		Name = id,
		BackgroundColor3 = COLORS[id],

		Text = Computed(scope, function(use)
			return if tFind(BLACKLIST, id) then use(self.filterInfo[id].Text) else upper(id)
		end),
		Visible = Computed(scope, function(use)
			return if tFind(BLACKLIST, id) then use(self.filterInfo[id].Visible) else true
		end),
		Size = Computed(scope, function(use)
			if tFind(BLACKLIST, id) then
				return if id == "Pin" then use(self.filterInfo.Pin.Size) else fromScale(0.116, 1)
			else
				return fromScale(0.12, 1)
			end
		end),

		[Fusion.Children] = {
			Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use)
					return if use(self.chosenFilter) == id and not tFind(BLACKLIST, id) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			if self.equipClickCD then return end
			if peek(self.chosenFilter) == id then return end

			if id == "Equip" then
				local item = _findItem(peek(self.itemFrame))

				if item == "None" then return end

				local itemInfo = ItemBook:FindItem(item)
				local itemType = itemInfo.Type :: string
				if not itemType then return end

				--- equip
				local slot = _checkSlot(self, itemType)
				local checkSame, sameSlot = _checkSameItem(self, item, itemType)

				if slot == "Full" and checkSame == "None" then Signals.CreateHint:Fire("Not enough space to equip!") return end
				if slot ~= "Full" and checkSame == "None" then
					Events.EquipItems:Fire(itemType, slot, item)

				elseif checkSame == "Exist" then
					Events.EquipItems:Fire("Clear" .. itemType, sameSlot, item)
				end

			elseif id == "Use" then
				local item = _findItem(peek(self.itemFrame))

				if item == "None" then return end

				local itemInfo = ItemBook:FindItem(item)
				local itemType = itemInfo.Type :: string
				if not itemType then return end

				--- actives
				if itemType == "Active" and not itemInfo.IsSkill then
					Events.UseItem:Fire(item)
					return
				end

			elseif id == "Pin" then
				local item = _findItem(peek(self.itemFrame))
				if item == "None" then return end

				Events.UpdatePinnedItems:Fire(item)

			else
				self.chosenFilter:set(id)
				self.items:set(self.inventory:GetChildren())

				self:DeselectAll()
			end

			self.equipClickCD = true
			wait(0.2)
			self.equipClickCD = false
		end,
	})
end

return FilterButtonBackpack
