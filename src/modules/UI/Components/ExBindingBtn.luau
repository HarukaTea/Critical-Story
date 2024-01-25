--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OnEvent, peek = Fusion.OnEvent, Fusion.peek

local color3New = Color3.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local POSITIONS = { Menu = fromScale(-0.19, 0), Backpack = fromScale(1.06, 0) }
local ICONS = { Menu = "rbxassetid://12180639811", Backpack = "rbxassetid://2970814599" }
local ICON_COLORS = { Menu = color3New(1, 1, 1), Backpack = fromRGB(148, 148, 148) }
local KEYS = { Menu = "X", Backpack = "C" }
local OPENS = { Menu = "AdventurerMenu", Backpack = "Backpack" }
local STROKES_ENABLE = { Menu = Fusion.Value(false), Backpack = Fusion.Value(false) }

local function ExCharButton(id: string, self: table): Frame
	return Fusion.New("Frame")({
		Name = id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.135, 1),

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
				Image = ICONS[id],
				ImageColor3 = ICON_COLORS[id],
				ZIndex = 3,

				[OnEvent("MouseEnter")] = function()
					STROKES_ENABLE[id]:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					STROKES_ENABLE[id]:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plrGui = self.plrGui :: PlayerGui

					peek(self.UI).BG.Visible = false
					self.plr:SetAttribute("CurrentMenu", id)
					plrGui[OPENS[id]].Shadow.Visible = true
					plrGui[OPENS[id]].BG.Visible = true
					plrGui.PlayerList.Enabled = false
					workspace.CurrentCamera.UIBlur.Enabled = true
				end,
			}),
			Components.TextLabel({
				Name = "Key",
				Position = fromScale(-0.165, -0.17),
				Size = fromScale(0.6, 0.6),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = KEYS[id],

				[Fusion.Children] = { Components.TextUIStroke({ Thickness = 2.5 }) },
			}),
		},
	})
end

return ExCharButton
