--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local New, Children, OnEvent, Computed, Value, Hydrate, Tween =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Computed, Fusion.Value, Fusion.Hydrate, Fusion.Tween

local color3New, v2New = Color3.new, Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp
local wait = task.wait

local NAMES = { HP = "HEALTH" }
local COLORS = {
	HP = fromRGB(48, 121, 36),
	HPMid = fromRGB(148, 148, 0),
	HPLow = fromRGB(203, 0, 0),
}
local STROKES_TRANS = {
	HP = Value(1),
}

local function StatBar(id: string, self: table): Frame
	local charStatsDict = self.charStatsDict
	Hydrate(self.char)({
		[Fusion.AttributeChange("InCombat")] = function(newState: boolean)
			charStatsDict.IsInCombat:set(newState)
		end
	})
	Hydrate(self.humanoid)({
		[Fusion.OnChange("Health")] = function(health: number)
			charStatsDict.HP[1]:set(health)
		end,
		[Fusion.OnChange("MaxHealth")] = function(health: number)
			charStatsDict.HP[2]:set(health)
		end
	})

	local function exCategoryOpened()
		STROKES_TRANS[id]:set(1)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return New("Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		Size = fromScale(0.25, 0.875),
		BackgroundColor3 = color3New(),

		[Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 2.5,
				Enabled = true,

				Transparency = Tween(Computed(function(use)
					return use(STROKES_TRANS[id])
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			New("Frame")({
				Name = "Bar",
				BackgroundColor3 = Tween(Computed(function(use)
					local HP, maxHP = use(self.charStatsDict[id][1]) :: number, use(self.charStatsDict[id][2]) :: number

					if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
						return COLORS.HPMid
					elseif HP / maxHP <= 0.33 then
						return COLORS.HPLow
					else
						return COLORS.HP
					end
				end), AssetBook.TweenInfos.onceHalf),
				ZIndex = 0,
				Size = Tween(Computed(function(use)
					local x = clamp(use(self.charStatsDict[id][1]) / use(self.charStatsDict[id][2]), 0, 1)

					return fromScale(x, 1)
				end), AssetBook.TweenInfos.halfBack),

				[Children] = { Components.RoundUICorner() },
			}),
			Components.HoverImageButton({
				ZIndex = 2,

				[OnEvent("MouseEnter")] = function()
					STROKES_TRANS[id]:set(0.3)
				end,
				[OnEvent("MouseLeave")] = function()
					STROKES_TRANS[id]:set(1)
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
			Components.TextLabel({
				Name = "Level",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(-0.52, 0),
				Size = fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTransparency = 0.4,
				Text = Computed(function(use)
					return "Lv." .. use(self.playerData.Levels)
				end),
			})
		},
	})
end

return StatBar
