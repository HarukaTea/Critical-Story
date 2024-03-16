--!strict

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New = Fusion.Children, Fusion.New

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ItemDescFrame(self: table): Frame
	return Components.Frame({
		Name = "Desc",
		Position = fromScale(0.853, 0.572),
		Size = fromScale(0.25, 0.651),
		[Fusion.Ref] = self.itemDescFrame,

		[Children] = {
			Components.CenterTextLabel({
				Name = "ItemName",
				Position = fromScale(0.5, 0.052),
				Size = fromScale(0.9, 0.075),
			}),
			Components.CenterTextLabel({
				Name = "ItemType",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),
			}),
			Components.CenterTextLabel({
				Name = "ItemTier",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
			Components.CenterTextLabel({
				Name = "ItemStats",
				Position = fromScale(0.5, 0.414),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Top,
				RichText = true,
				TextScaled = false,
				TextSize = Fusion.Computed(function(use)
					return use(self.absTextSize)
				end),
				TextWrapped = true,

				[Children] = {
					New("UITextSizeConstraint")({ MaxTextSize = 35 }),
				},
			}),
			Components.CenterTextLabel({
				Name = "ItemDesc",
				Position = fromScale(0.5, 0.825),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextScaled = false,
				TextSize = Fusion.Computed(function(use)
					return use(self.absTextSize) - 3
				end),
				TextWrapped = true,
				TextColor3 = fromRGB(186, 186, 186),

				[Children] = {
					New("UITextSizeConstraint")({ MaxTextSize = 32 }),
				},
			}),
			New("Frame")({
				Name = "HorizonLine",
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.21),
				Size = fromScale(0.9, 0.005),
				Visible = false,
				BackgroundTransparency = 0.5
			}),
		},
	})
end

return ItemDescFrame
