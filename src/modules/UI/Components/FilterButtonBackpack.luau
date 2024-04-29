--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local peek = Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait = task.wait
local upper = string.upper
local tFind = table.find
local sFind = string.find

local COLORS = {
	Passive = fromRGB(40, 98, 3),
	Active = fromRGB(167, 111, 83),
	Others = fromRGB(0, 130, 139),

	Equip = fromRGB(85, 85, 85),
	Pin = fromRGB(93, 47, 140),
}
local BLACKLIST = { "Equip", "Pin" }

local function _checkSlot(self: table, type: string) : string
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

	for _, element in classFrame:GetDescendants() do
		if sFind(element.Name, type) and not element:GetAttribute("Equipped") then
			return element.Name
		end
	end

	return "Full"
end
local function _checkSameItem(self: table, item: string, type: string) : (string, string?)
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

	local check, sameSlot = false, nil
	for _, element in classFrame:GetDescendants() do
		if sFind(element.Name, type) and element:GetAttribute("ItemEquipped") == item then
			check = true
			sameSlot = element.Name
		end
	end

	return if not check then "None" else "Exist", sameSlot
end
local function _findItem(itemFrame: Frame) : string
	local item: string?
	for _, child in itemFrame:GetChildren() do
		if child:IsA("ImageButton") and child:GetAttribute("Selected") then
			item = child.Name
		end
	end
	if not item then return "None" end

	return item
end

local function FilterButton(id: string, self: table): TextButton
	return Components.TextButton({
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = upper(id),
		Size = fromScale(0.116, 1),

		[Fusion.Children] = {
			Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(Fusion.Computed(function(use)
					return if use(self.chosenFilter) == id and not tFind(BLACKLIST, id) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			if self.equipClickCD then return end

			if peek(self.chosenFilter) == id then
				self.chosenFilter:set("All")
				return
			end

			if id == "Equip" then
				local item = _findItem(peek(self.itemFrame))
				local itemType = AssetBook.Items.ItemType[item]
				if item == "None" or not itemType then return end

				--- equip
				local slot = _checkSlot(self, itemType)
				local checkSame, sameSlot = _checkSameItem(self, item, itemType)

				if slot == "Full" and checkSame == "None" then Signals.CreateHint:Fire("Not enough space to equip!", "Error") return end
				if slot ~= "Full" and checkSame == "None" then
					Events.EquipItems:Fire(itemType, slot, item)

				elseif checkSame == "Exist" then
					Events.EquipItems:Fire("Clear" .. itemType, sameSlot, item)
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

return FilterButton
