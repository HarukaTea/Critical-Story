--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function ItemDescFrame(self: table): Frame
	local scope = self.scope

	return Components.Frame(scope, {
		Name = "Desc",
		Position = fromScale(0.853, 0.572),
		Size = fromScale(0.25, 0.651),

		[Children] = {
			New(scope, "UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.05, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}),
			Components.TextLabel(scope, {
				Name = "ItemName",
				Position = fromScale(0.5, 0.052),
				Size = fromScale(0.9, 0.075),
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				Text = Computed(scope, function(use)
					return use(self.itemName)
				end),
				TextColor3 = Computed(scope, function(use)
					return use(self.itemTierColor)
				end),

				[Fusion.OnChange("AbsoluteSize")] = function(newAbSize: Vector2)
					self.absStatSize:set(newAbSize.Y)
				end,
			}),
			Components.TextLabel(scope, {
				Name = "ItemStats",
				Position = fromScale(0.5, 0.414),
				Size = fromScale(0.9, 0),
				TextYAlignment = Enum.TextYAlignment.Top,
				RichText = true,
				TextScaled = false,
				TextWrapped = true,
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.Y,

				TextSize = Computed(scope, function(use)
					return use(self.absStatSize) - 2
				end),
				Text = Computed(scope, function(use)
					return use(self.itemStats)
				end),

				[Children] = {
					New(scope, "UITextSizeConstraint")({ MaxTextSize = 35 }),
				},
			}),
			Components.TextLabel(scope, {
				Name = "ItemDesc",
				Position = fromScale(0.5, 0.825),
				Size = fromScale(0.9, 0),
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextScaled = false,
				TextWrapped = true,
				TextTransparency = 0.6,
				AnchorPoint = v2New(0.5, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.Y,
				FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),

				Text = Computed(scope, function(use)
					return use(self.itemDesc)
				end),
				TextSize = Computed(scope, function(use)
					return use(self.absStatSize) - 5
				end),

				[Children] = {
					New(scope, "UITextSizeConstraint")({ MaxTextSize = 32 }),
				},
			}),
		},
	})
end

return ItemDescFrame
