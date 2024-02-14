--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ProgressCircle = require(RepS.Modules.UI.Components.ProgressCircle)

local OnEvent, Computed, Children, Value = Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.Value

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale

local POSITIONS = { 0, 0.355, 0.71, 0.866 }
local STROKES_ENABLE = { Value(false), Value(false), Value(false), Value(false) }

local function ActiveSlot(id: string, self: table): Frame
	return Fusion.New("Frame")({
		Name = "Active"..id,
		BackgroundColor3 = color3New(),
		Position = fromScale(POSITIONS[id], 0),
		Size = fromScale(0.281, 0.658),
		[Fusion.Ref] = self.activeList[id],

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 3,
				Enabled = Computed(function(use)
					return use(STROKES_ENABLE[id])
				end)
			}),
			Components.HoverImageButton({
				Name = "Hover",
				ZIndex = 3,

				[OnEvent("MouseEnter")] = function()
					STROKES_ENABLE[id]:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					STROKES_ENABLE[id]:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					self:UseItem(id)
				end,
			}),
			Components.ImageLabel({
				Name = "Icon",
				Size = fromScale(1, 1),
				Image = Computed(function(use)
					local item = use(self.activeIconList[id]) :: string

					if AssetBook.Items.ItemImages[item] then
						return AssetBook.Items.ItemImages[item]
					else
						return AssetBook.Items.ItemImages.Unknown
					end
				end)
			}),
			Components.TextLabel({
				Name = "Amount",
				Position = fromScale(-0.02, 0.72),
				Size = fromScale(1.25, 0.365),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,
				Text = Computed(function(use)
					local amount = use(self.activeAmountList[id]) :: number

					if amount == 1 or amount == 0 then
						return ""
					else
						return "x"..amount
					end
				end),

				[Children] = {
					Components.TextUIStroke({ Thickness = 2.5 }),
				},
			}),
			Components.TextLabel({
				Name = "Cooldown",
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.5),
				Size = fromScale(1, 1),
				BackgroundTransparency = 0.4,
				ZIndex = 2,
				TextStrokeTransparency = 0,
				Text = Computed(function(use)
					return use(self.activeCDText[id])
				end),
				Visible = false,

				[Children] = {
					Components.RoundUICorner(),
					Fusion.New("UIPadding")({
						PaddingTop = udNew(0.2, 0),
						PaddingLeft = udNew(0.2, 0),
						PaddingRight = udNew(0.2, 0),
						PaddingBottom = udNew(0.2, 0),
					}),
					Components.TextUIStroke({ Thickness = 2.5 })
				},
			}),
			Components.TextLabel({
				Name = "Key",
				BackgroundColor3 = color3New(),
				BackgroundTransparency = 0,
				Position = fromScale(0.316, 1.109),
				Size = fromScale(0.361, 0.362),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = id,

				[Children] = { Fusion.New("UICorner")({ CornerRadius = udNew(0.3, 0) })},
			}),

			ProgressCircle("Left", self, id),
			ProgressCircle("Right", self, id),
		},
	})
end

return ActiveSlot
