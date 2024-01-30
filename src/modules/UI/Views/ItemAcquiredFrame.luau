--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ItemBar = require(RepS.Modules.UI.Components.ItemBar)

local Children, New, Value = Fusion.Children, Fusion.New, Fusion.Value

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale

local function ItemAcquiredFrame(self: table): Frame
	return Components.Frame({
		Name = "ItemAcquiredFrame",
		AnchorPoint = v2New(0.5, 0),
		Position = fromScale(0.5, -1.15),

		[Children] = {
			New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = udNew(0.15, 0),
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
			Fusion.ForValues(self.newAddedItems, function(use, item: string)
				local info = {
					Icon = AssetBook.Items.ItemImages[item],
					Name = AssetBook.Items.ItemName[item],
					TierColor = AssetBook.TierColor[AssetBook.Items.ItemTier[item]],
					Position = Value(fromScale(-0.45, 0))
				}

				return ItemBar(info)
			end, Fusion.cleanup),
		},
	})
end

return ItemAcquiredFrame
