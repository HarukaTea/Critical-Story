--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local peek = Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find

local COLORS = {
	Character = fromRGB(172, 113, 86),
	Party = fromRGB(52, 104, 156),
	Settings = fromRGB(53, 107, 79),

	Passive = fromRGB(40, 98, 3),
	Active = fromRGB(167, 111, 83),
	Others = fromRGB(0, 130, 139),
	Equip = fromRGB(85, 85, 85),
	Pin = fromRGB(93, 47, 140),
}
local VISIBLES = { Equip = true, Pin = true }

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
local function _closeOther(self: table, id: string)
	local mainFrames = { "BottomLeft", "Top" }
	for _, frame in peek(self.UI).BG:GetChildren() do
		if frame:IsA("Frame") and not tFind(mainFrames, frame.Name) then
			frame.Visible = false
		end
	end

	peek(self.UI).BG[id].Visible = true
end
local function _onClick(id: string, self: table)
	if peek(self.chosenFilter) == id then
		self.chosenFilter:set("All")
		return
	end

	if id == "Equip" then
		local item = _findItem(peek(self.itemFrame))
		local itemType = AssetBook.Items.ItemType[item]
		if item == "None" or not itemType then return end

		--- equip
		local slot = self:CheckSlot(itemType) :: string?
		local checkSame: string, sameSlot: string = self:CheckSameItem(item, itemType)

		if slot ~= "Full" and checkSame == "None" then
			Events.EquipItems:Fire(itemType, slot, item)

		elseif checkSame == "Exist" then
			Events.EquipItems:Fire("Clear" .. itemType, sameSlot, item)
		end

	elseif id == "Pin" then
		local item = _findItem(peek(self.itemFrame))
		if item == "None" then return end

		local btnsRightFrame = peek(self.btnsFrame.Right) :: Frame
		Events.UpdatePinnedItems:Fire(item)

		if btnsRightFrame.Pin.Text == "Pin" then
			btnsRightFrame.Pin.Text = "Unpin"
			peek(self.itemFrame)[item].Pinned.Visible = if self.inventory[item]:GetAttribute("Equipped") then false else true
		else
			btnsRightFrame.Pin.Text = "Pin"
			peek(self.itemFrame)[item].Pinned.Visible = false
		end

	elseif id == "Character" or id == "Settings" or id == "Party" then
		_closeOther(self, id)

	else
		self.chosenFilter:set(id)
		self.items:set(self.inventory:GetChildren())

		self:DeselectAll()
	end
end

local function FilterButton(id: string, self: table): TextButton
	return Components.TextButton({
		Name = id,
		BackgroundColor3 = COLORS[id],
		Text = id,
		Size = fromScale(0.116, 1),
		Visible = if VISIBLES[id] then false else true,

		[Fusion.Children] = {
			Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
		},
		[Fusion.OnEvent("MouseButton1Click")] = function()
			_onClick(id, self)
		end,
	})
end

return FilterButton
