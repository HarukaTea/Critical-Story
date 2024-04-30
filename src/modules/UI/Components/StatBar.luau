--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Computed, Tween = Fusion.Computed, Fusion.Tween

local color3New, v2New = Color3.new, Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp

local function StatBar(id: string, self: table): Frame
	local colors = {
		HP = fromRGB(48, 121, 36),
		HPMid = fromRGB(148, 148, 0),
		HPLow = fromRGB(203, 0, 0),
	}
	local isSelecting = Fusion.Value(false)

	local charStatsDict = self.charStatsDict
	Fusion.Hydrate(self.humanoid)({
		[Fusion.OnChange("Health")] = function(health: number)
			charStatsDict.HP[1]:set(health)
		end,
		[Fusion.OnChange("MaxHealth")] = function(health: number)
			charStatsDict.HP[2]:set(health)
		end
	})

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New("Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		Size = fromScale(0.25, 0.875),
		BackgroundColor3 = color3New(),

		[Fusion.Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 2.5,
				Enabled = true,

				Transparency = Tween(Computed(function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Fusion.New("Frame")({
				Name = "Bar",
				BackgroundColor3 = Tween(Computed(function(use)
					local HP, maxHP = use(self.charStatsDict[id][1]) :: number, use(self.charStatsDict[id][2]) :: number

					if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
						return colors.HPMid
					elseif HP / maxHP <= 0.33 then
						return colors.HPLow
					else
						return colors.HP
					end
				end), AssetBook.TweenInfos.onceHalf),
				ZIndex = 0,
				Size = Tween(Computed(function(use)
					local x = clamp(use(self.charStatsDict[id][1]) / use(self.charStatsDict[id][2]), 0, 1)

					return fromScale(x, 1)
				end), AssetBook.TweenInfos.halfBack),

				[Fusion.Children] = { Components.RoundUICorner() },
			}),
			Components.HoverImageButton({
				ZIndex = 2,

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
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
				Text = "HEALTH",
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
