--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local PointsButton = require(RepS.Modules.UI.Components.PointsButton)

local Children, New, Value, AttributeChange, Hydrate, Tween, Computed, OnEvent, peek =
	Fusion.Children,
	Fusion.New,
	Fusion.Value,
	Fusion.AttributeChange,
	Fusion.Hydrate,
	Fusion.Tween,
	Fusion.Computed,
	Fusion.OnEvent,
	Fusion.peek

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BlockPart(pos: UDim2, size: UDim2): Frame
	return New("Frame")({
		BackgroundTransparency = 0.9,
		Position = pos,
		Size = size,
	})
end
local function LinePart(pos: UDim2, direction: string, color: Color3, face: string): Frame
	local rotation: number
	if face == "Up" then
		rotation = -45
	elseif face == "Down" then
		rotation = 45
	else
		rotation = 0
	end

	return New("Frame")({
		BackgroundTransparency = 0.5,
		BackgroundColor3 = color,
		Position = pos,
		Size = if direction == "X" then fromScale(0.074, 0.011) else fromScale(0.059, 0.011),
		Rotation = rotation,
	})
end

local function CharacterFrame(self: table): Frame
	local plr, char = self.plr :: Player, self.char :: Model
	self.playerData = {
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		ATK = Value(plr:GetAttribute("ATKPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
		Gold = Value(plr:GetAttribute("Gold"))
	}
	self.charData = {
		ATK = Value(char:GetAttribute("ATKDMG")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth)
	}
	local playerData, charData = self.playerData, self.charData

	Hydrate(plr)({
		[AttributeChange("Levels")] = function(level: number)
			playerData.Levels:set(level)
		end,
		[AttributeChange("LvPoints")] = function(point: number)
			playerData.LvPoints:set(point)
		end,
		[AttributeChange("ATKPoints")] = function(point: number)
			playerData.ATK:set(point)
		end,
		[AttributeChange("HealthPoints")] = function(point: number)
			playerData.Health:set(point)
		end,
		[AttributeChange("ShieldPoints")] = function(point: number)
			playerData.Shield:set(point)
		end,
		[AttributeChange("Gold")] = function(gold: number)
			playerData.Gold:set(gold)
		end
	})
	Hydrate(char)({
		[AttributeChange("ATKDMG")] = function(dmg: number)
			charData.ATK:set(dmg)
		end,
		[AttributeChange("MaxShield")] = function(shield: number)
			charData.Shield:set(shield)
		end
	})
	Hydrate(char.Humanoid)({
		[Fusion.OnChange("MaxHealth")] = function(hp: number)
			charData.Health:set(hp)
		end
	})

	local bgColor = Value(fromRGB(30, 30, 30))
	local contentColor = Value(fromRGB(255, 255, 255))

	return Components.Frame({
		Name = "Character",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 3.856 }),
			New("Frame")({
				Name = "CharacterSelfView",
				BackgroundTransparency = 1,
				Position = fromScale(0.393, 0),
				Size = fromScale(0.221, 1),

				[Children] = {
					BlockPart(fromScale(0.35, 0.035), fromScale(0.294, 0.202)),
					BlockPart(fromScale(0.297, 0.266), fromScale(0.4, 0.376)),
					BlockPart(fromScale(0.729, 0.266), fromScale(0.198, 0.376)),
					BlockPart(fromScale(0.07, 0.266), fromScale(0.198, 0.376)),
					BlockPart(fromScale(0.297, 0.667), fromScale(0.188, 0.305)),
					BlockPart(fromScale(0.51, 0.667), fromScale(0.188, 0.305)),
				},
			}),
			Components.Frame({
				Name = "Lines",

				[Children] = {
					LinePart(fromScale(0.579, 0.532), "XY", fromRGB(255, 0, 0), "Down"),
					LinePart(fromScale(0.63, 0.613), "X", fromRGB(255, 0, 0), "Line"),
					LinePart(fromScale(0.42, 0.25), "XY", fromRGB(85, 255, 0), "Down"),
					LinePart(fromScale(0.355, 0.17), "X", fromRGB(85, 255, 0), "Line"),
					LinePart(fromScale(0.417, 0.813), "XY", fromRGB(255, 255, 0), "Up"),
					LinePart(fromScale(0.352, 0.892), "X", fromRGB(255, 255, 0), "Line"),
					LinePart(fromScale(0.507, 0.023), "XY", fromRGB(255, 85, 0), "Up"),
					LinePart(fromScale(0.556, -0.057), "X", fromRGB(255, 85, 0), "Line"),
				},
			}),
			Components.Frame({
				Name = "PointSection",

				[Children] = {
					PointsButton("ATK", "Right", self),
					PointsButton("Health", "Left", self),
					PointsButton("Shield", "Left", self),
				},
			}),
			Components.TextLabel({
				Name = "PointsLeft",
				Position = fromScale(0.61, 1.013),
				Size = fromScale(0.374, 0.08),
				TextXAlignment = Enum.TextXAlignment.Right,
				Text = Computed(function(use)
					return "SKILL POINTS LEFT: "..use(playerData.LvPoints)
				end)
			}),
			Components.TextButton({
				Name = "Reset",
				Position = fromScale(0.647, -0.094),
				Size = fromScale(0.09, 0.078),
				Text = "RESET",
				TextColor3 = Tween(Computed(function(use)
					return use(contentColor)
				end), AssetBook.TweenInfos.twiceHalf),
				BackgroundColor3 = Tween(Computed(function(use)
					return use(bgColor)
				end), AssetBook.TweenInfos.twiceHalf),

				[OnEvent("MouseEnter")] = function()
					bgColor:set(fromRGB(255, 255, 255))
					contentColor:set(fromRGB())
				end,
				[OnEvent("MouseLeave")] = function()
					bgColor:set(fromRGB(30, 30, 30))
					contentColor:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseButton1Click")] = function()
					local cost = ((peek(playerData.Levels) - 1) * 2 - peek(playerData.LvPoints)) * 20

					if peek(playerData.Gold) >= cost and cost ~= 0 then
						Events.AddPoints:Fire("Reset")
					elseif cost > 0 then
						Signals.CreateHint:Fire("You don't have enough gold to reset!", "Error")
					end
				end,

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(Computed(function(use)
							return if use(bgColor) == fromRGB(30, 30, 30) then fromRGB(255, 85, 0) else fromRGB()
						end), AssetBook.TweenInfos.twiceHalf),
					}),
					New("UIPadding")({ PaddingBottom = udNew(0, 1) })
				}
			}),
			Components.TextLabel({
				Name = "ResetCost",
				Position = fromScale(0.752, -0.106),
				Size = fromScale(0.146, 0.1),
				FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
				TextColor3 = fromRGB(255, 255, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Computed(function(use)
					local cost = ((use(playerData.Levels) - 1) * 2 - use(playerData.LvPoints)) * 20

					return "COST: "..HarukaLib:NumberConvert(cost, "%.1f").." GOLD"
				end),
			})
		},
	})
end

return CharacterFrame
