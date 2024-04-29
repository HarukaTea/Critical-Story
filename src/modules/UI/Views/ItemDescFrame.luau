--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Value, Computed, Tween =
	Fusion.Children, Fusion.New, Fusion.Value, Fusion.Computed, Fusion.Tween

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function ItemDescFrame(self: table): Frame
	self.absStatSize = Value(0)
	self.itemName, self.itemType, self.itemTier, self.itemStats, self.itemDesc =
		Value(""), Value(""), Value(""), Value(""), Value("")
	self.horizonLineVisible = Value(false)
	self.itemTypeColor, self.itemTierColor = Value(fromRGB()), Value(fromRGB())

	return Components.Frame({
		Name = "Desc",
		Position = fromScale(0.853, 0.572),
		Size = fromScale(0.25, 0.651),

		[Children] = {
			Components.CenterTextLabel({
				Name = "ItemName",
				Position = fromScale(0.5, 0.052),
				Size = fromScale(0.9, 0.075),

				Text = Computed(function(use)
					return use(self.itemName)
				end)
			}),
			Components.CenterTextLabel({
				Name = "ItemType",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),

				Text = Computed(function(use)
					return use(self.itemType)
				end),
				TextColor3 = Tween(Computed(function(use)
					return use(self.itemTypeColor)
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.CenterTextLabel({
				Name = "ItemTier",
				Position = fromScale(0.5, 0.152),
				Size = fromScale(0.9, 0.068),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(function(use)
					return use(self.itemTier)
				end),
				TextColor3 = Tween(Computed(function(use)
					return use(self.itemTierColor)
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.CenterTextLabel({
				Name = "ItemStats",
				Position = fromScale(0.5, 0.414),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Top,
				RichText = true,
				TextScaled = false,
				TextSize = Fusion.Computed(function(use)
					return use(self.absStatSize) / 5
				end),
				TextWrapped = true,

				Text = Computed(function(use)
					return use(self.itemStats)
				end),

				[Fusion.OnChange("AbsoluteSize")] = function(newAbSize: Vector2)
					self.absStatSize:set(newAbSize.Y)
				end,

				[Children] = {
					New("UITextSizeConstraint")({ MaxTextSize = 30 }),
				},
			}),
			Components.CenterTextLabel({
				Name = "ItemDesc",
				Position = fromScale(0.5, 0.825),
				Size = fromScale(0.9, 0.345),
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextScaled = false,
				TextSize = Fusion.Computed(function(use)
					return use(self.absStatSize) / 5 - 3
				end),
				TextWrapped = true,
				TextTransparency = 0.6,

				Text = Computed(function(use)
					return use(self.itemDesc)
				end),

				[Children] = {
					New("UITextSizeConstraint")({ MaxTextSize = 27 }),
				},
			}),
			New("Frame")({
				Name = "HorizonLine",
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.21),
				Size = fromScale(0.9, 0.005),

				BackgroundTransparency = Tween(Computed(function(use)
					return if use(self.horizonLineVisible) then 0.5 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
		},
	})
end

return ItemDescFrame
