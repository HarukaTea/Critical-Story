--!nocheck
--!optimize 2
--!native

local Fusion = require(game:GetService("ReplicatedStorage").Modules.Packages.Fusion)

local New = Fusion.New

local udNew = UDim.new
local fromScale = UDim2.fromScale

local function BottomBtns(direction: "Left" | "Right", btns: table): Frame
	return New("Frame")({
		Name = "Bottom" .. direction,
		BackgroundTransparency = 1,
		Size = fromScale(0.945, 0.05),
		Position = fromScale(0.02, 0.922),

		[Fusion.Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 48.504 }),
			New("UIListLayout")({
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

return BottomBtns
