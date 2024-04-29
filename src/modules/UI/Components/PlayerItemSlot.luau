--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local color3New = Color3.new
local fromScale = UDim2.fromScale

local POSITIONS = {
	fromScale(0.164, 0.391),
	fromScale(0.401, 0.391),
	fromScale(0.637, 0.391),
	fromScale(0.048, 0.558),
	fromScale(0.28, 0.558),
	fromScale(0.516, 0.558),
	fromScale(0.753, 0.558),
}

local function Slot(id: string): ImageLabel
	return Fusion.New("ImageLabel")({
		Name = "Slot" .. id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.19, 0.165),
		Image = AssetBook.Items.ItemImages.Null,

		[Fusion.Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({ Thickness = 3 }),
		},
	})
end

return Slot
