--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OnEvent, Children, Computed, peek =
	Fusion.OnEvent, Fusion.Children, Fusion.Computed, Fusion.peek

local color3New = Color3.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udNew = UDim.new

local POSITIONS = { Menu = fromScale(0.355, -1.1), Backpack = fromScale(0.71, -1.1) }
local ICON_COLORS = { Menu = color3New(1, 1, 1), Backpack = fromRGB(148, 148, 148) }
local KEYS = { Menu = "C", Backpack = "B" }
local OPENS = { Menu = "AdventurerMenu", Backpack = "Backpack" }
local STROKES_TRANS = { Menu = Fusion.Value(1), Backpack = Fusion.Value(1) }

local function ExCharButton(id: string, self: table): Frame
	return Fusion.New("Frame")({
		Name = id,
		BackgroundColor3 = color3New(),
		Position = POSITIONS[id],
		Size = fromScale(0.281, 0.658),

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,
				Transparency = Fusion.Tween(Computed(function(use)
					return use(STROKES_TRANS[id])
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.HoverImageButton({
				Name = "Hover",
				Image = Computed(function(use)
					if id == "Backpack" then
						return "rbxassetid://2970814599"
					else
						return AssetBook.ClassInfo[use(self.playerData.Class)].Image
					end
				end),
				ImageColor3 = ICON_COLORS[id],
				ZIndex = 3,

				[OnEvent("MouseEnter")] = function()
					STROKES_TRANS[id]:set(0)
				end,
				[OnEvent("MouseLeave")] = function()
					STROKES_TRANS[id]:set(1)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plrGui = self.plrGui :: PlayerGui

					peek(self.UI).Enabled = false
					self.plr:SetAttribute("CurrentMenu", id)
					plrGui[OPENS[id]].Shadow.Visible = true
					plrGui[OPENS[id]].BG.Visible = true
					plrGui.PlayerList.Enabled = false
					workspace.CurrentCamera.UIBlur.Enabled = true

					for _, child in peek(self.UI).BG:GetDescendants() do
						if child:IsA("UIStroke") and child.Color == fromRGB(255, 255, 255) then child.Transparency = 1 end
					end

					if id == "Menu" then
						workspace.Sounds.SFXs.MapOpen:Play()

					elseif id == "Backpack" then
						workspace.Sounds.SFXs.Equip:Play()
					end
				end,
			}),
			Components.TextLabel({
				Name = "Key",
				BackgroundColor3 = color3New(),
				BackgroundTransparency = 0,
				Position = fromScale(0.316, 1.109),
				Size = fromScale(0.361, 0.362),
				ZIndex = 4,
				TextStrokeTransparency = 0,
				Text = KEYS[id],

				[Children] = { Fusion.New("UICorner")({ CornerRadius = udNew(0.3, 0) })},
			}),

			Components.ImageLabel({
				Name = "Hint",
				BackgroundColor3 = fromRGB(255, 85, 0),
				BackgroundTransparency = 0,
				Position = fromScale(0.65, 0),
				Size = fromScale(0.3, 0.3),
				ZIndex = 3,
				Visible = Computed(function(use)
					return if use(self.playerData.LvPoints) > 0 and id == "Menu" then true else false
				end),

				[Children] = { Components.RoundUICorner() }
			})
		},
	})
end

return ExCharButton
