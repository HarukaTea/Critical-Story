--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed, Tween, OnEvent, Value, peek =
	Fusion.Children, Fusion.New, Fusion.Computed, Fusion.Tween, Fusion.OnEvent, Fusion.Value, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local upper = string.upper

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
	DMG = "DmgPoints",
	Health = "HealthPoints",
	Mana = "ManaPoints",
	Shield = "ShieldPoints",
	Magic = "MagicPoints"
}

local function PointsButton(id: string, direction: string, self: table): Frame
	local bgColors = { Value(fromRGB(30, 30, 30)), Value(fromRGB(30, 30, 30)) }
	local contentColors = { Value(fromRGB(255, 255, 255)), Value(fromRGB(255, 255, 255)) }

	return New("Frame")({
        Name = id,
		BackgroundTransparency = 1,
		Position = POS[id],
		Size = fromScale(0.177, 0.1),

		[Children] = {
			Components.TextLabel({
				Name = "Stat",
				Size = fromScale(1, 1),
				FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
				TextXAlignment = if direction == "Left" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
				TextColor3 = COLORS[id],
                Text = Computed(function(use)
					if id ~= "DMG" then
						return upper(id)..": "..use(self.playerData[id]).." ("..use(self.charData[id])..")"
					else
						return "DMG: "..use(self.playerData[id]).." ("..use(self.charData.MinDMG).."-"..use(self.charData.MaxDMG)..")"
					end
				end)
			}),
			Components.TextButton({
				Name = "Add",
				Size = fromScale(0.15, 1),
				Position = if direction == "Left" then fromScale(-0.195, 0) else fromScale(1.05, 0),
				Text = "+",
				Visible = Computed(function(use)
					return if use(self.playerData.LvPoints) > 0 then true else false
				end),

				BackgroundColor3 = Tween(Computed(function(use)
					return use(bgColors[1])
				end), AssetBook.TweenInfos.twiceHalf),
				TextColor3 = Tween(Computed(function(use)
					return use(contentColors[1])
				end), AssetBook.TweenInfos.twiceHalf),

				[OnEvent("MouseEnter")] = function()
					bgColors[1]:set(fromRGB(255, 255, 255))
					contentColors[1]:set(fromRGB())
				end,
				[OnEvent("MouseLeave")] = function()
					bgColors[1]:set(fromRGB(30, 30, 30))
					contentColors[1]:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseButton1Click")] = function()
					if peek(self.playerData.LvPoints) > 0 then
						workspace.Sounds.SFXs.Ding:Play()

						Events.AddPoints:Fire(POINTS[id], 1)
					else
						Signals.CreateHint:Fire("You don't have enough skill points!", "Error")
					end
				end,

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(Computed(function(use)
							return if use(bgColors[1]) == fromRGB(30, 30, 30) then COLORS[id] else fromRGB()
						end))
					})
				}
			}),
			Components.TextButton({
				Name = "Add10",
				Size = fromScale(0.28, 1),
				Position = if direction == "Left" then fromScale(-0.565, 0) else fromScale(1.29, 0),
				Text = "+10",
				Visible = Computed(function(use)
					return if use(self.playerData.LvPoints) >= 10 then true else false
				end),

				BackgroundColor3 = Tween(Computed(function(use)
					return use(bgColors[2])
				end), AssetBook.TweenInfos.twiceHalf),
				TextColor3 = Tween(Computed(function(use)
					return use(contentColors[2])
				end), AssetBook.TweenInfos.twiceHalf),

				[OnEvent("MouseEnter")] = function()
					bgColors[2]:set(fromRGB(255, 255, 255))
					contentColors[2]:set(fromRGB())
				end,
				[OnEvent("MouseLeave")] = function()
					bgColors[2]:set(fromRGB(30, 30, 30))
					contentColors[2]:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseButton1Click")] = function()
					if peek(self.playerData.LvPoints) >= 10 then
						workspace.Sounds.SFXs.Ding:Play()

						Events.AddPoints:Fire(POINTS[id], 10)
					else
						Signals.CreateHint:Fire("You don't have enough skill points!", "Error")
					end
				end,

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(Computed(function(use)
							return if use(bgColors[2]) == fromRGB(30, 30, 30) then COLORS[id] else fromRGB()
						end))
					})
				}
			})
		},
	})
end

return PointsButton
