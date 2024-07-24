--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed, OnEvent, Value, peek =
	Fusion.Children, Fusion.New, Fusion.Computed, Fusion.OnEvent, Fusion.Value, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local upper = string.upper
local fontFromName = Font.fromName

local function CharPointsBtn(id: string, direction: string, self: table): Frame
	local scope = self.scope :: Fusion.Scope
	local COLORS = {
		DMG = fromRGB(255, 0, 0),
		Health = fromRGB(85, 255, 0),
		Mana = fromRGB(0, 255, 255),
		Shield = fromRGB(255, 255, 0),
		Magic = fromRGB(170, 170, 255),
	}
	local POS = {
		DMG = fromScale(0.721, 0.732),
		Health = fromScale(0.669, 0.322),
		Mana = fromScale(0.162, 0.125),
		Shield = fromScale(0.162, 0.847),
		Magic = fromScale(0.106, 0.556),
	}
	local POINTS = {
		DMG = "DMGPoints",
		Health = "HealthPoints",
		Mana = "ManaPoints",
		Magic = "MagicPoints"
	}
	local bgColors = Value(scope, fromRGB(30, 30, 30))
	local contentColors = Value(scope, fromRGB(255, 255, 255))

	return New(scope, "Frame")({
        Name = id,
		BackgroundTransparency = 1,
		Position = POS[id],
		Size = fromScale(0.177, 0.1),

		[Children] = {
			Components.TextLabel(scope, {
				Name = "Stat",
				Size = fromScale(1, 1),
				FontFace = fontFromName("TitilliumWeb", Enum.FontWeight.Bold),
				TextXAlignment = if direction == "Left" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
				TextColor3 = COLORS[id],

                Text = Computed(scope, function(use: Fusion.Use)
					if id ~= "DMG" then
						return upper(id)..": "..use(self.playerData[id]).." ("..use(self.charData[id])..")"
					else
						return "DMG: "..use(self.playerData[id]).." ("..use(self.charData.MinDMG).."-"..use(self.charData.MaxDMG)..")"
					end
				end)
			}),
			Components.TextButton(scope, {
				Name = "Add",
				Size = fromScale(0.15, 1),
				Position = if direction == "Left" then fromScale(-0.195, 0) else fromScale(1.05, 0),
				Text = "+",

				BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
					return use(bgColors)
				end),
				TextColor3 = Computed(scope, function(use: Fusion.Use)
					return use(contentColors)
				end),

				[OnEvent("MouseEnter")] = function()
					bgColors:set(fromRGB(255, 255, 255))
					contentColors:set(fromRGB())
				end,
				[OnEvent("MouseLeave")] = function()
					bgColors:set(fromRGB(30, 30, 30))
					contentColors:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseButton1Click")] = function()
					if peek(self.playerData.LvPoints) > 0 then
						local pointPerAdd = tonumber(peek(self.pointsPerAdd))

						if pointPerAdd then
							local check = HarukaLib:TypeCheck("MinMax", pointPerAdd, 0, 99999)
							local check2 = HarukaLib:TypeCheck("Integer", pointPerAdd)

							if not check or not check2 then
								Signals.CreateHint:Fire("Wrong input number!")
								return
							end
						else
							Signals.CreateHint:Fire("Wrong input number!")
							return
						end

						if peek(self.playerData.LvPoints) < pointPerAdd then
							Signals.CreateHint:Fire("You don't have enough skill points!")
							return
						end

						workspace.Sounds.SFXs.Ding:Play()

						Events.AddPoints.Fire({ Target = POINTS[id], Points = pointPerAdd })
					else
						Signals.CreateHint:Fire("You don't have enough skill points!")
					end
				end,

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Computed(scope, function(use: Fusion.Use)
							return if use(bgColors) == fromRGB(30, 30, 30) then COLORS[id] else fromRGB()
						end)
					})
				}
			})
		},
	})
end

return CharPointsBtn
