--!nocheck
--!optimize 2
--!native

local Fusion = require(game:GetService("ReplicatedStorage").Modules.Packages.Fusion)

local udNew = UDim.new
local fromScale = UDim2.fromScale

local function FilterBG(direction: "Left" | "Right", btns: table, self: table): Frame
	if not self.btnsFrame then self.btnsFrame = { Left = Fusion.Value(), Right = Fusion.Value() } end

	return Fusion.New("Frame")({
		Name = "Bottom" .. direction,
		BackgroundTransparency = 1,
		Size = fromScale(0.945, 0.05),
		Position = fromScale(0.02, 0.922),
		[Fusion.Ref] = self.btnsFrame[direction],

		[Fusion.Children] = {
			Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 48.504 }),
			Fusion.New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = udNew(0.012, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = if direction == "Right"
					then Enum.HorizontalAlignment.Right
					else Enum.HorizontalAlignment.Left,
			}),

			btns,
		},
	})
end

return FilterBG
