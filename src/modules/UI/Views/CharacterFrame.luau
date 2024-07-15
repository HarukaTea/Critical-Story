--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local CharPointsBtn = require(RepS.Modules.UI.Components.CharPointsBtn)

local Children, New, Tween, Computed, OnEvent, peek =
	Fusion.Children,
	Fusion.New,
	Fusion.Tween,
	Fusion.Computed,
	Fusion.OnEvent,
	Fusion.peek

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function BlockPart(scope: Fusion.Scope, pos: UDim2, size: UDim2): Frame
	return New(scope, "Frame")({
		BackgroundTransparency = 0.9,
		Position = pos,
		Size = size,
	})
end
local function LinePart(scope: Fusion.Scope, pos: UDim2, direction: string, color: Color3, face: string): Frame
	local rotation: number
	if face == "Up" then
		rotation = -45
	elseif face == "Down" then
		rotation = 45
	else
		rotation = 0
	end

	return New(scope, "Frame")({
		BackgroundTransparency = 0.5,
		BackgroundColor3 = color,
		Position = pos,
		Size = if direction == "X" then fromScale(0.074, 0.011) else fromScale(0.059, 0.011),
		Rotation = rotation,
	})
end

local function CharacterFrame(self: table): Frame
	local scope = self.scope :: Fusion.Scope
	local plr, char = self.plr :: Player, self.char :: Model
	local playerData, charData = self.playerData, self.charData

	table.insert(scope, HarukaLib:Hydrate(plr, {
		["Attr-Levels"] = function(levels: number)
			playerData.Levels:set(levels)
		end,
		["Attr-LvPoints"] = function(points: number)
			playerData.LvPoints:set(points)
		end,
		["Attr-DMGPoints"] = function(points: number)
			playerData.DMG:set(points)
		end,
		["Attr-MagicPoints"] = function(points: number)
			playerData.Magic:set(points)
		end,
		["Attr-HealthPoints"] = function(points: number)
			playerData.Health:set(points)
		end,
		["Attr-ManaPoints"] = function(points: number)
			playerData.Mana:set(points)
		end,
		["Attr-Gold"] = function(gold: number)
			playerData.Gold:set(gold)
		end
	}))
	table.insert(scope, HarukaLib:Hydrate(char, {
		["Attr-MinDMG"] = function(dmg: number)
			charData.MinDMG:set(dmg)
		end,
		["Attr-MaxDMG"] = function(dmg: number)
			charData.MaxDMG:set(dmg)
		end,
		["Attr-Magic"] = function(magic: number)
			charData.Magic:set(magic)
		end,
		["Attr-MaxShield"] = function(shield: number)
			charData.Shield:set(shield)
		end,
		["Attr-MaxMana"] = function(mana: number)
			charData.Mana:set(mana)
		end
	}))
	table.insert(scope, HarukaLib:Hydrate(char.Humanoid, {
		["Prop-MaxHealth"] = function(maxHP: number)
			charData.Health:set(maxHP)
		end
	}))

	local isSelecting = Fusion.Value(scope, false)

	return Components.Frame(scope, {
		Name = "Character",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),

		Visible = Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Character)
		end),

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.856 }),
			New(scope, "Frame")({
				Name = "CharacterSelfView",
				BackgroundTransparency = 1,
				Position = fromScale(0.393, 0),
				Size = fromScale(0.221, 1),

				[Children] = {
					BlockPart(scope, fromScale(0.35, 0.035), fromScale(0.294, 0.202)),
					BlockPart(scope, fromScale(0.297, 0.266), fromScale(0.4, 0.376)),
					BlockPart(scope, fromScale(0.729, 0.266), fromScale(0.198, 0.376)),
					BlockPart(scope, fromScale(0.07, 0.266), fromScale(0.198, 0.376)),
					BlockPart(scope, fromScale(0.297, 0.667), fromScale(0.188, 0.305)),
					BlockPart(scope, fromScale(0.51, 0.667), fromScale(0.188, 0.305)),
				},
			}),
			Components.Frame(scope, {
				Name = "Lines",

				[Children] = {
					LinePart(scope, fromScale(0.58, 0.698), "XY", fromRGB(255, 0, 0), "Down"),
					LinePart(scope, fromScale(0.631, 0.779), "X", fromRGB(255, 0, 0), "Line"),
					LinePart(scope, fromScale(0.531, 0.447), "XY", fromRGB(85, 255, 0), "Up"),
					LinePart(scope, fromScale(0.58, 0.367), "X", fromRGB(85, 255, 0), "Line"),
					LinePart(scope, fromScale(0.369, 0.524), "XY", fromRGB(170, 170, 255), "Up"),
					LinePart(scope, fromScale(0.305, 0.603), "X", fromRGB(170, 170, 255), "Line"),
					LinePart(scope, fromScale(0.42, 0.25), "XY", fromRGB(0, 255, 255), "Down"),
					LinePart(scope, fromScale(0.355, 0.17), "X", fromRGB(0, 255, 255), "Line"),
					LinePart(scope, fromScale(0.507, 0.023), "XY", fromRGB(255, 85, 0), "Up"),
					LinePart(scope, fromScale(0.556, -0.057), "X", fromRGB(255, 85, 0), "Line"),
				},
			}),
			Components.Frame(scope, {
				Name = "PointSection",

				[Children] = {
					CharPointsBtn("DMG", "Right", self),
					CharPointsBtn("Health", "Right", self),
					CharPointsBtn("Mana", "Left", self),
					CharPointsBtn("Magic", "Left", self),
				},
			}),

			Components.Frame(scope, {
				Name = "BottomRight",
				Size = fromScale(0.418, 0.08),
				Position = fromScale(0.566, 1.013),
				AnchorPoint = Vector2.new(),

				[Children] = {
					New(scope, "UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right
					}),
					Components.TextBox(scope, {
						Name = "PointsPerAdd",
						Size = fromScale(0.2, 1),

						Text = Computed(scope, function(use: Fusion.Use)
							return use(self.pointsPerAdd)
						end),
						[Fusion.Out("Text")] = self.pointsPerAdd,

						[Children] = { Components.RoundUICorner(scope) }
					}),
					Components.TextLabel(scope, {
						Name = "PointsLeft",
						Size = fromScale(0.5, 1),
						RichText = true,

						Text = Computed(scope, function(use: Fusion.Use)
							return [[SKILL POINTS LEFT:  <font color="#f6e58d">]]..use(playerData.LvPoints).."</font>"
						end)
					}),
				}
			}),

			Components.TextButton(scope, {
				Name = "Reset",
				Position = fromScale(0.647, -0.094),
				Size = fromScale(0.09, 0.078),
				Text = "RESET",

				TextColor3 = Computed(scope, function(use: Fusion.Use)
					return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
				end),
				BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
					return if not use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
				end),

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local cost = ((peek(playerData.Levels) - 1) * 2 - peek(playerData.LvPoints)) * 20

					if peek(playerData.Gold) >= cost and cost ~= 0 then
						Events.AddPoints:Fire("Reset")

					elseif cost > 0 then
						Signals.CreateHint:Fire("You don't have enough gold to reset!")
					end
				end,

				[Children] = {
					New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke(scope, {
						Transparency = 0.2,
						Thickness = 2.5,
						Enabled = true,

						Color = Tween(scope, Computed(scope, function(use: Fusion.Use)
							return if not use(isSelecting) then fromRGB(255, 85, 0) else fromRGB()
						end), AssetBook.TweenInfos.twiceHalf),
					}),
					New(scope, "UIPadding")({ PaddingBottom = udNew(0, 1) })
				}
			}),
			Components.TextLabel(scope, {
				Name = "ResetCost",
				Position = fromScale(0.752, -0.106),
				Size = fromScale(0.146, 0.1),
				FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
				TextXAlignment = Enum.TextXAlignment.Left,

				Text = Computed(scope, function(use: Fusion.Use)
					local cost = ((use(playerData.Levels) - 1) * 2 - use(playerData.LvPoints)) * 20

					return "COST: "..HarukaLib:NumberConvert(cost, "%.1f").." GOLD"
				end),
				TextColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
					local cost = ((use(playerData.Levels) - 1) * 2 - use(playerData.LvPoints)) * 20
					local have = use(playerData.Gold)

					return if cost > have then fromRGB(255, 0, 0) else fromRGB(255, 255, 0)
				end), AssetBook.TweenInfos.twiceHalf)
			})
		},
	})
end

return CharacterFrame
