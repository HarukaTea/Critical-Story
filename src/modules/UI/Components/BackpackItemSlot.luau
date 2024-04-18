--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, OnEvent, Value, Computed, peek =
	Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Computed, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BackpackItemSlot(item: IntConstrainedValue, self: table): ImageButton
	local amount = Value(item.Value)
	local equipped = Value(item:GetAttribute("Equipped"))
	local pinned = Value(item:GetAttribute("Pinned"))

	local stroke_trans = Value(1)

	Fusion.Hydrate(item)({
		[Fusion.OnChange("Value")] = function(newAmount)
			amount:set(newAmount)
		end,
		[Fusion.AttributeChange("Equipped")] = function(state)
			equipped:set(state)

			peek(self.btnsFrame.Right).Equip.Text = if state then "Unequip" else "Equip"
		end,
		[Fusion.AttributeChange("Pinned")] = function(state)
			pinned:set(state)

			peek(self.btnsFrame.Right).Pin.Text = if state then "Unpin" else "Pin"
		end
	})

	item = item.Name
	return Components.HoverImageButton({
		Name = item,
		BackgroundTransparency = 0,
		Image = AssetBook.Items.ItemImages[item],

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,
				Transparency = Fusion.Tween(Computed(function(use)
					return use(stroke_trans)
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.TextLabel({
				Name = "Equipped",
				AnchorPoint = v2New(0.5, 0.5),
				BackgroundColor3 = fromRGB(68, 135, 203),
				BackgroundTransparency = 0,
				Position = fromScale(0.9, 0.1),
				Size = fromScale(0.5, 0.5),
				ZIndex = 2,
				Text = "E",
				Visible = Computed(function(use)
					return use(equipped)
				end),

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
				Visible = Computed(function(use)
					if not use(equipped) then
						return use(pinned)
					end
				end),

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
				Text = Computed(function(use)
					local itemAmount = use(amount) :: number

					if itemAmount == 1 or itemAmount == 0 then
						return ""
					else
						return "x"..itemAmount
					end
				end),
			}),
		},
		[OnEvent("MouseEnter")] = function()
			stroke_trans:set(0)
			peek(self.itemFrame)[item].UIStroke.Enabled = true
		end,
		[OnEvent("MouseLeave")] = function()
			stroke_trans:set(if peek(self.itemFrame)[item]:GetAttribute("Selected")
				then 0
				else 1)
		end,
		[OnEvent("MouseButton1Click")] = function()
			local itemFrame, itemDescFrame, btnsFrame =
				peek(self.itemFrame) :: Frame, peek(self.itemDescFrame) :: Frame, peek(self.btnsFrame.Right) :: Frame

			if itemFrame[item]:GetAttribute("Selected") then
				self:DeselectAll()
				return
			end

			self:DeselectAll(self)

			itemFrame[item]:SetAttribute("Selected", true)
			itemFrame[item].UIStroke.Enabled = true
			stroke_trans:set(0)

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
			btnsFrame.Equip.Text = if peek(equipped) then "Unequip" else "Equip"
			btnsFrame.Pin.Visible = true
			btnsFrame.Pin.Text = if peek(pinned) then "Unpin" else "Pin"
			btnsFrame.Pin.Size = if btnsFrame.Equip.Visible
				then fromScale(0.116, 1)
				else fromScale(0.237, 1)
		end,
	})
end

return BackpackItemSlot
