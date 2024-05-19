--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Computed, Tween =
	Fusion.Children, Fusion.New, Fusion.Computed, Fusion.Tween

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function ItemDescFrame(self: table): Frame
	local scope = self.scope

	return Components.Frame(scope, {
		Name = "Desc",
		Position = fromScale(0.853, 0.572),
		Size = fromScale(0.25, 0.651),

		[Children] = {
			Components.TextLabel(scope, {
				Name = "ItemName",
				Position = fromScale(0.5, 0.052),
				Size = fromScale(0.9, 0.075),
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				Text = Computed(scope, function(use)
					return use(self.itemName)
				end)
			}),
			Components.TextLabel(scope, {
				Name = "ItemType",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				Text = Computed(scope, function(use)
					return use(self.itemType)
				end),
				TextColor3 = Tween(scope, Computed(scope, function(use)
					return use(self.itemTypeColor)
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.TextLabel(scope, {
				Name = "ItemTier",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(scope, function(use)
					return use(self.itemTier)
				end),
				TextColor3 = Tween(scope, Computed(scope, function(use)
					return use(self.itemTierColor)
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.TextLabel(scope, {
				Name = "ItemStats",
				Position = fromScale(0.5, 0.414),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Top,
				RichText = true,
				TextScaled = false,
				TextWrapped = true,
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				TextSize = Computed(scope, function(use)
					return use(self.absStatSize) / 5
				end),
				Text = Computed(scope, function(use)
					return use(self.itemStats)
				end),

				[Fusion.OnChange("AbsoluteSize")] = function(newAbSize: Vector2)
					self.absStatSize:set(newAbSize.Y)
				end,

				[Children] = {
					New(scope, "UITextSizeConstraint")({ MaxTextSize = 30 }),
				},
			}),
			Components.TextLabel(scope, {
				Name = "ItemDesc",
				Position = fromScale(0.5, 0.825),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextScaled = false,
				TextWrapped = true,
				TextTransparency = 0.6,
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				Text = Computed(scope, function(use)
					return use(self.itemDesc)
				end),
				TextSize = Computed(scope, function(use)
					return use(self.absStatSize) / 5 - 3
				end),

				[Children] = {
					New(scope, "UITextSizeConstraint")({ MaxTextSize = 27 }),
				},
			}),
			New(scope, "Frame")({
				Name = "HorizonLine",
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.21),
				Size = fromScale(0.9, 0.005),

				BackgroundTransparency = Tween(scope, Computed(scope, function(use)
					return if use(self.horizonLineVisible) then 0.5 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
		},
	})
end

return ItemDescFrame
