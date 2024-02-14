--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children, OnEvent, Computed, Value, Hydrate, AttributeChange =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Computed, Fusion.Value, Fusion.Hydrate, Fusion.AttributeChange

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp
local wait = task.wait

local NAMES = { HP = "HEALTH", MP = "MANA", DEF = "SHIELD" }
local COLORS = {
	HP = fromRGB(48, 121, 36),
	HPMid = fromRGB(148, 148, 0),
	HPLow = fromRGB(203, 0, 0),
	MP = fromRGB(73, 67, 167),
	DEF = fromRGB(167, 115, 56),
	DEFRepairing = fromRGB(72, 166, 176),
}
local STROKES_ENABLE = {
	HP = Value(false),
	MP = Value(false),
	DEF = Value(false)
}

local function StatBar(id: string, self: table): Frame
	local char, humanoid = self.char :: Model, self.humanoid :: Humanoid
	self.charStatsDict = {
		HP = { Value(humanoid.Health), Value(humanoid.MaxHealth) },
		MP = { Value(char:GetAttribute("Mana")), Value(char:GetAttribute("MaxMana")) },
		DEF = { Value(char:GetAttribute("Shield")), Value(char:GetAttribute("MaxShield")) },
		DEFRepairing = Value(false), HPHealing = Value(false),

		MonsterAmount = Value({}),
		IsInCombat = Value(false),
		EffectsList = Value({}),
	}
	local charStatsDict = self.charStatsDict
	Hydrate(self.char)({
		[AttributeChange("Mana")] = function(mana)
			charStatsDict.MP[1]:set(mana)
		end,
		[AttributeChange("MaxMana")] = function(mana)
			charStatsDict.MP[2]:set(mana)
		end,
		[AttributeChange("Shield")] = function(shield)
			charStatsDict.DEF[1]:set(shield)
		end,
		[AttributeChange("MaxShield")] = function(shield)
			charStatsDict.DEF[2]:set(shield)
		end,

		--- ui state related
		[AttributeChange("Repairing")] = function(state)
			charStatsDict.DEFRepairing:set(state)
		end,
		[AttributeChange("Healing")] = function(state)
			charStatsDict.HPHealing:set(state)
		end,
		[AttributeChange("InCombat")] = function(state)
			charStatsDict.IsInCombat:set(state)
		end,
	})
	Hydrate(self.humanoid)({
		[Fusion.OnChange("Health")] = function(health)
			charStatsDict.HP[1]:set(health)
		end,
		[Fusion.OnChange("MaxHealth")] = function(health)
			charStatsDict.HP[2]:set(health)
		end
	})

	local function _setEffectsChildren()
		wait()
		self.charStatsDict.EffectsList:set(self.charData.EffectsList:GetChildren())
	end
	Hydrate(self.charData.EffectsList)({
		[OnEvent("ChildAdded")] = _setEffectsChildren,
		[OnEvent("ChildRemoved")] = _setEffectsChildren
	})

	local children: TextLabel?
	if id == "DEF" then
		children = Components.TextLabel({
			Name = "Level",
			AnchorPoint = v2New(0.5, 0),
			Position = fromScale(-0.52, 0),
			Size = fromScale(0.94, 1),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextStrokeTransparency = 0,
			TextTransparency = 0.1,
			Text = Computed(function(use)
				return "Lv." .. use(self.playerData.Levels)
			end),

			[Children] = { Components.TextUIStroke({ Thickness = 2.5 }) }
		})
	end

	return New("Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		Size = if id == "HP" then fromScale(0.215, 0.875) else fromScale(0.185, 0.875),
		BackgroundColor3 = color3New(),

		[Children] = {
			New("UICorner")({ CornerRadius = udNew(0.5, 0) }),
			Components.UIStroke({
				Thickness = 2.5,
				Enabled = Computed(function(use)
					return use(STROKES_ENABLE[id])
				end)
			}),
			New("Frame")({
				Name = "Bar",
				BackgroundColor3 = Fusion.Tween(Computed(function(use)
					if id == "HP" then
						if use(self.charStatsDict.HPHealing) then
							return COLORS.DEFRepairing
						end

						local HP, maxHP = use(self.charStatsDict[id][1]) :: number, use(self.charStatsDict[id][2]) :: number

						if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
							return COLORS.HPMid
						elseif HP / maxHP <= 0.33 then
							return COLORS.HPLow
						else
							return COLORS.HP
						end
					elseif id == "DEF" then
						return if use(self.charStatsDict.DEFRepairing) then COLORS.DEFRepairing else COLORS.DEF
					else
						return COLORS[id]
					end
				end), AssetBook.TweenInfos.onceHalf),
				ZIndex = 0,
				Size = Fusion.Tween(
					Computed(function(use)
						local x = clamp(use(self.charStatsDict[id][1]) / use(self.charStatsDict[id][2]), 0, 1)

						return fromScale(x, 1)
					end),
					AssetBook.TweenInfos.halfBack
				),

				[Children] = { Components.RoundUICorner() },
			}),
			Components.HoverImageButton({
				Name = "Hover",
				ZIndex = 2,

				[OnEvent("MouseEnter")] = function()
					STROKES_ENABLE[id]:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					STROKES_ENABLE[id]:set(false)
				end,
			}),
			Components.TextLabel({
				Name = "Stat",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0),
				Size = fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextStrokeTransparency = 0.7,
				Text = Computed(function(use)
					return use(self.charStatsDict[id][1]) .. "/" .. use(self.charStatsDict[id][2])
				end),
			}),
			Components.TextLabel({
				Name = "Title",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0),
				Size = fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextStrokeTransparency = 0.7,
				Text = NAMES[id],
			}),

			children
		},
	})
end

return StatBar
