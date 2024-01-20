--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = HarukaFrameworkClient.Fusion

local ProgressCircle = require(RepS.Modules.UI.Components.ProgressCircle)

local OnEvent, Computed, Children, Value = Fusion.OnEvent, Fusion.Computed, Fusion.Children, Fusion.Value

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale

local POSITIONS = { 0, 0.2, 0.666, 0.866 }
local STROKES_ENABLE = { Value(false), Value(false), Value(false), Value(false) }

local function ActiveSlot(id: string, self: table): Frame
	return Fusion.New("Frame")({
		Name = if id == 1 then "ClassSkill" else "Active"..tostring(id - 1),
		BackgroundColor3 = color3New(),
		Position = fromScale(POSITIONS[id], 0),
		Size = fromScale(0.135, 1),
		[Fusion.Ref] = self.activeList[id],

		[Fusion.Attribute("Equipped")] = if id == 1 then true else false,

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
					self:UseItem(id - 1)
				end,
			}),
			Components.ImageLabel({
				Name = "Icon",
				Size = fromScale(1, 1),
				Image = Computed(function(use)
					if id == 1 then
						return AssetBook.ClassInfo[use(self.charStatsDict.PlayerData.Class)].SkillImage
					else
						return AssetBook.Items.ItemImages.Null
					end
				end),
				ImageColor3 = Computed(function(use)
					local class = use(self.charStatsDict.PlayerData.Class)

					if AssetBook.ClassInfo[class].CAIcon then
						return color3New(1, 1, 1)
					else
						return if id == 1 then AssetBook.ClassInfo[class].Color else color3New(1, 1, 1)
					end
				end)
			}),
			Components.TextLabel({
				Name = "Amount",
				Position = fromScale(-0.02, 0.617),
				Size = fromScale(1.25, 0.365),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,

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
				Position = fromScale(-0.25, -0.17),
				Size = fromScale(0.6, 0.6),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = if id == 1 then "F" else (id - 1),

				[Children] = { Components.TextUIStroke({ Thickness = 2.5 }) },
			}),

			ProgressCircle("Left", self, id),
			ProgressCircle("Right", self, id),
		},
	})
end

return ActiveSlot
