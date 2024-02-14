--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local PointsButton = require(RepS.Modules.UI.Components.PointsButton)

local Children, New, Value, AttributeChange, Hydrate, peek =
	Fusion.Children, Fusion.New, Fusion.Value, Fusion.AttributeChange, Fusion.Hydrate, Fusion.peek

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
		DMG = Value(plr:GetAttribute("DmgPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Mana = Value(plr:GetAttribute("ManaPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Gold = Value(plr:GetAttribute("Gold"))
	}
	self.charData = {
		DMG = Value(char:GetAttribute("Damage")),
		Magic = Value(char:GetAttribute("Magic")),
		Mana = Value(char:GetAttribute("MaxMana")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth)
	}
	local playerData, charData = self.playerData, self.charData

	Hydrate(plr)({
		[AttributeChange("Levels")] = function(level)
			playerData.Levels:set(level)
		end,
		[AttributeChange("LvPoints")] = function(point)
			playerData.LvPoints:set(point)
		end,
		[AttributeChange("DmgPoints")] = function(point)
			playerData.DMG:set(point)
		end,
		[AttributeChange("HealthPoints")] = function(point)
			playerData.Health:set(point)
		end,
		[AttributeChange("ManaPoints")] = function(point)
			playerData.Mana:set(point)
		end,
		[AttributeChange("ShieldPoints")] = function(point)
			playerData.Shield:set(point)
		end,
		[AttributeChange("MagicPoints")] = function(point)
			playerData.Magic:set(point)
		end,
		[AttributeChange("Gold")] = function(gold)
			playerData.Gold:set(gold)
		end
	})
	Hydrate(char)({
		[AttributeChange("Damage")] = function(dmg)
			charData.DMG:set(dmg)
		end,
		[AttributeChange("Magic")] = function(magic)
			charData.Magic:set(magic)
		end,
		[AttributeChange("MaxMana")] = function(mana)
			charData.Mana:set(mana)
		end,
		[AttributeChange("MaxShield")] = function(shield)
			charData.Shield:set(shield)
		end
	})
	Hydrate(char.Humanoid)({
		[Fusion.OnChange("MaxHealth")] = function(hp)
			charData.Health:set(hp)
		end
	})

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
					LinePart(fromScale(0.58, 0.698), "XY", fromRGB(255, 0, 0), "Down"),
					LinePart(fromScale(0.631, 0.779), "X", fromRGB(255, 0, 0), "Line"),
					LinePart(fromScale(0.531, 0.447), "XY", fromRGB(85, 255, 0), "Up"),
					LinePart(fromScale(0.58, 0.367), "X", fromRGB(85, 255, 0), "Line"),
					LinePart(fromScale(0.417, 0.813), "XY", fromRGB(255, 255, 0), "Up"),
					LinePart(fromScale(0.352, 0.892), "X", fromRGB(255, 255, 0), "Line"),
					LinePart(fromScale(0.369, 0.524), "XY", fromRGB(170, 170, 255), "Up"),
					LinePart(fromScale(0.305, 0.603), "X", fromRGB(170, 170, 255), "Line"),
					LinePart(fromScale(0.42, 0.25), "XY", fromRGB(0, 255, 255), "Down"),
					LinePart(fromScale(0.355, 0.17), "X", fromRGB(0, 255, 255), "Line"),
					LinePart(fromScale(0.507, 0.023), "XY", fromRGB(255, 85, 0), "Up"),
					LinePart(fromScale(0.556, -0.057), "X", fromRGB(255, 85, 0), "Line"),
				},
			}),
			Components.Frame({
				Name = "PointSection",

				[Children] = {
					PointsButton("DMG", "Right", self),
					PointsButton("Health", "Right", self),
					PointsButton("Shield", "Left", self),
					PointsButton("Mana", "Left", self),
					PointsButton("Magic", "Left", self),
				},
			}),
			Components.TextLabel({
				Name = "PointsLeft",
				Position = fromScale(0.61, 1.013),
				Size = fromScale(0.374, 0.08),
				TextXAlignment = Enum.TextXAlignment.Right,
				Text = Fusion.Computed(function(use)
					return "SKILL POINTS LEFT: "..use(self.playerData.LvPoints)
				end)
			}),
			Components.TextButton({
				Name = "Reset",
				Position = fromScale(0.647, -0.094),
				Size = fromScale(0.09, 0.078),
				Text = "RESET",

				[Fusion.OnEvent("MouseButton1Click")] = function()
					local playerData = self.playerData :: table
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
						Color = fromRGB(255, 85, 0),
						Thickness = 2.5,
						Enabled = true,
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
				Text = Fusion.Computed(function(use)
					local playerData = self.playerData :: table
					local cost = ((use(playerData.Levels) - 1) * 2 - use(playerData.LvPoints)) * 20

					return "COST: "..HarukaLib:NumberConvert(cost, "%.1f").." GOLD"
				end),
			})
		},
	})
end

return CharacterFrame
