--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, OnEvent, peek = Fusion.Children, Fusion.OnEvent, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BackpackItemSlot(item: string, self: table): ImageButton
	return Components.HoverImageButton({
		Name = item,
		BackgroundTransparency = 0,
		Image = AssetBook.Items.ItemImages[item],

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({ Thickness = 3 }),
			Components.TextLabel({
				Name = "Equipped",
				AnchorPoint = v2New(0.5, 0.5),
				BackgroundColor3 = fromRGB(68, 135, 203),
				BackgroundTransparency = 0,
				Position = fromScale(0.9, 0.1),
				Size = fromScale(0.5, 0.5),
				ZIndex = 2,
				Text = "E",
				Visible = if self.inventory[item]:GetAttribute("Equipped") then true else false,

				[Children] = {
					Components.RoundUICorner(),
					Components.NormalUIPadding(),
				},
			}),
			Components.TextLabel({
				Name = "Pinned",
				AnchorPoint = v2New(0.5, 0.5),
				BackgroundColor3 = fromRGB(124, 63, 189),
				BackgroundTransparency = 0,
				Position = fromScale(0.9, 0.1),
				Size = fromScale(0.5, 0.5),
				ZIndex = 3,
				Text = "P",
				Visible = if self.inventory[item]:GetAttribute("Pinned")
						and not self.inventory[item]:GetAttribute("Equipped")
					then true
					else false,

				[Children] = {
					Components.RoundUICorner(),
					Components.NormalUIPadding(),
				},
			}),
			Components.TextLabel({
				Name = "Amount",
				Position = fromScale(0.2, 0.65),
				Size = fromScale(1, 0.35),
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,
				Text = self.inventory[item].Value > 1 and "x" .. self.inventory[item].Value or "",
			}),
		},
		[OnEvent("MouseEnter")] = function()
			peek(self.itemFrame)[item].UIStroke.Enabled = true
		end,
		[OnEvent("MouseLeave")] = function()
			peek(self.itemFrame)[item].UIStroke.Enabled = if peek(self.itemFrame)[item]:GetAttribute("Selected")
				then true
				else false
		end,
		[OnEvent("MouseButton1Click")] = function()
			local itemFrame, itemDescFrame, btnsFrame =
				peek(self.itemFrame) :: Frame, peek(self.itemDescFrame) :: Frame, peek(self.btnsFrame.Right) :: Frame

			if itemFrame[item]:GetAttribute("Selected") then
				self:DeselectAll()
				return
			end

			self:DeselectAll()

			itemFrame[item]:SetAttribute("Selected", true)
			itemFrame[item].UIStroke.Enabled = true

			local itemType = AssetBook.Items.ItemType[item]

			itemDescFrame.HorizonLine.Visible = true
			itemDescFrame.ItemName.Text = AssetBook.Items.ItemName[item]
			itemDescFrame.ItemType.Text = itemType
			itemDescFrame.ItemTier.Text = AssetBook.Items.ItemTier[item]
			itemDescFrame.ItemStats.Text = AssetBook.Items.ItemStat[item]
			itemDescFrame.ItemDesc.Text = AssetBook.Items.ItemDesc[item]

			itemDescFrame.ItemType.TextColor3 = AssetBook.TypeColor[itemType]
			itemDescFrame.ItemTier.TextColor3 = AssetBook.TierColor[AssetBook.Items.ItemTier[item]]

			btnsFrame.Equip.Visible = if itemType ~= "Material" then true else false
			btnsFrame.Pin.Visible = true
			btnsFrame.Pin.Text = if self.inventory[item]:GetAttribute("Pinned") then "Unpin" else "Pin"
			btnsFrame.Pin.Size = if btnsFrame.Equip.Visible
				then fromScale(0.116, 1)
				else fromScale(0.237, 1)
		end,
	})
end

return BackpackItemSlot
