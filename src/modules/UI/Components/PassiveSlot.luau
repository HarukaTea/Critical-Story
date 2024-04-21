--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Value = Fusion.Value

local color3New = Color3.new
local fromScale = UDim2.fromScale

local POSITIONS = {
	fromScale(0, 0),
	fromScale(0.355, 0),
	fromScale(0.71, 0),
	fromScale(0, -0.8),
	fromScale(0.355, -0.8)
}
local STROKES_TRANS = {
	Value(1),
	Value(1),
	Value(1),
	Value(1),
	Value(1),
}

local function PassiveSlot(id: string, self: table): Frame

	local function exCategoryOpened()
		STROKES_TRANS[id]:set(1)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New("Frame")({
		Name = "Passive" .. id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.281, 0.658),

		[Fusion.Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,
				Transparency = Fusion.Tween(Fusion.Computed(function(use)
					return use(STROKES_TRANS[id])
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.ImageLabel({
				Name = "Icon",
				Size = fromScale(1, 1),
				Image = Fusion.Computed(function(use)
					local item = use(self.passiveIconList[id]) :: string

					if AssetBook.Items.ItemImages[item] then
						return AssetBook.Items.ItemImages[item]
					else
						return AssetBook.Items.ItemImages.Unknown
					end
				end),
			}),
			Components.HoverImageButton({
				Visible = if UIS.TouchEnabled then false else true,

				[Fusion.OnEvent("MouseEnter")] = function()
					STROKES_TRANS[id]:set(0)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					STROKES_TRANS[id]:set(1)
				end,
			}),
		},
	})
end

return PassiveSlot
