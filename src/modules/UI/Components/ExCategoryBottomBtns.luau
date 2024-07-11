--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local New = Fusion.New

local udNew = UDim.new
local fromScale = UDim2.fromScale

local function ExCategoryBottomBtns(direction: "Left" | "Right", self: table, btns: table): Frame
	return New(self.scope, "Frame")({
		Name = "Bottom" .. direction,
		BackgroundTransparency = 1,
		Size = fromScale(0.945, 0.05),
		Position = fromScale(0.02, 0.922),

		[Fusion.Children] = {
			New(self.scope, "UIAspectRatioConstraint")({ AspectRatio = 47.089 }),
			New(self.scope, "UIListLayout")({
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

return ExCategoryBottomBtns
