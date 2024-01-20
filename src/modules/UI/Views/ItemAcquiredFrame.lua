--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Fusion = HarukaFrameworkClient.Fusion

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
			Fusion.ForValues(self.newAddedItems, function(use, item)
				workspace.Sounds.SFXs.ItemAcquired:Play()

				local info = {
					Icon = AssetBook.Items.ItemImages[item],
					Name = AssetBook.Items.ItemName[item],
					TierColor = AssetBook.TierColor[AssetBook.Items.ItemTier[item]],
					Position = Value(fromScale(-0.25, 0))
				}

				return ItemBar(info)
			end, Fusion.cleanup),
		},
	})
end

return ItemAcquiredFrame
