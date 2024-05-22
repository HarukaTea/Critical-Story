--!nocheck

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
local fontFromName = Font.fromName

local function CharPointsBtn(id: string, direction: string, self: table): Frame
	local scope = self.scope
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
	local bgColors = { Value(scope, fromRGB(30, 30, 30)), Value(scope, fromRGB(30, 30, 30)) }
	local contentColors = { Value(scope, fromRGB(255, 255, 255)), Value(scope, fromRGB(255, 255, 255)) }

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

                Text = Computed(scope, function(use)
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
				Visible = Computed(scope, function(use)
					return if use(self.playerData.LvPoints) > 0 then true else false
				end),

				BackgroundColor3 = Tween(scope, Computed(scope, function(use)
					return use(bgColors[1])
				end), AssetBook.TweenInfos.twiceHalf),
				TextColor3 = Tween(scope, Computed(scope, function(use)
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
						Signals.CreateHint:Fire("You don't have enough skill points!")
					end
				end,

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(scope, Computed(scope, function(use)
							return if use(bgColors[1]) == fromRGB(30, 30, 30) then COLORS[id] else fromRGB()
						end), AssetBook.TweenInfos.twiceHalf)
					})
				}
			}),
			Components.TextButton(scope, {
				Name = "Add10",
				Size = fromScale(0.28, 1),
				Position = if direction == "Left" then fromScale(-0.565, 0) else fromScale(1.29, 0),
				Text = "+10",
				Visible = Computed(scope, function(use)
					return if use(self.playerData.LvPoints) >= 10 then true else false
				end),

				BackgroundColor3 = Tween(scope, Computed(scope, function(use)
					return use(bgColors[2])
				end), AssetBook.TweenInfos.twiceHalf),
				TextColor3 = Tween(scope, Computed(scope, function(use)
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
						Signals.CreateHint:Fire("You don't have enough skill points!")
					end
				end,

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(scope, Computed(scope, function(use)
							return if use(bgColors[2]) == fromRGB(30, 30, 30) then COLORS[id] else fromRGB()
						end))
					})
				}
			})
		},
	})
end

return CharPointsBtn
