--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local udNew = UDim.new
local fromScale = UDim2.fromScale

local IMAGES = {
	DMG = "rbxassetid://2965862892",
	Magic = "rbxassetid://2965863231",
	Gold = "rbxassetid://4820492332",
	RP = "rbxassetid://16002068286",
}
local POSITIONS = {
	DMG = fromScale(-0.381, 0.192),
	Magic = fromScale(-0.381, 0.777),
	Gold = fromScale(1.37, 0.192),
	RP = fromScale(1.37, 0.777)
}
local function StatText(direction: "Left" | "Right", id: string, self: table): Frame
	return Components.Frame({
		Name = id,
		Position = POSITIONS[id],
		Size = fromScale(0.296, 0.5),

		[Children] = {
			Components.RoundUICorner(),
			Components.ImageLabel({
				BackgroundTransparency = 0,
				Position = if direction == "Left" then fromScale(0, 0) else fromScale(0.774, 0),
				Size = fromScale(0.22, 1),
				Image = IMAGES[id],

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Size = fromScale(0.7, 1),
				Position = if direction == "Left" then fromScale(0.3, 0) else fromScale(0, 0),
				TextXAlignment = if direction == "Right" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
				Text = Fusion.Computed(function(use)
					return use(self.playerData[id])
				end),

				[Children] = {
					Fusion.New("UIPadding")({
						PaddingTop = udNew(0, 1),
						PaddingBottom = udNew(0, 1),
					}),
					Components.TextUIStroke({ Thickness = 2.5 }),
				},
			}),
		},
	})
end

return StatText
