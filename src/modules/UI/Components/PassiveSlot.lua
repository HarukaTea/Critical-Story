--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = HarukaFrameworkClient.Fusion

local Value = Fusion.Value

local color3New = Color3.new
local fromScale = UDim2.fromScale

local POSITIONS = { fromScale(0.3, -0.979), fromScale(0.44, -1.36), fromScale(0.58, -1) }
local STROKES_ENABLE = { Value(false), Value(false), Value(false) }

local function PassiveSlot(id: string, self: table): Frame
	return Fusion.New("Frame")({
		Name = "Passive" .. id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.11, 0.81),

		[Fusion.Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 3,
				Enabled = Fusion.Computed(function(use)
					return use(STROKES_ENABLE[id])
				end)
			}),
			Components.HoverImageButton({
				Name = "Hover",
				Image = AssetBook.Items.ItemImages.Null,

				[Fusion.OnEvent("MouseEnter")] = function()
					STROKES_ENABLE[id]:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					STROKES_ENABLE[id]:set(false)
				end,
			}),
		},
	})
end

return PassiveSlot
