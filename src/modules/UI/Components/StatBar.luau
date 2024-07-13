--!nocheck

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
	local scope = self.scope :: Fusion.Scope
	local names = { HP = "HEALTH", MP = "MANA", DEF = "SHIELD" }
	local colors = {
		HP = fromRGB(48, 121, 36),
		HPMid = fromRGB(148, 148, 0),
		HPLow = fromRGB(203, 0, 0),
		MP = fromRGB(19, 95, 176),
		DEF = fromRGB(167, 115, 56),
		DEFRepairing = fromRGB(72, 166, 176),
	}
	local isSelecting = Fusion.Value(scope, false)

	local children: TextLabel
	if id == "DEF" or id == "HP" then
		children = Components.TextLabel(scope, {
			Name = "Level",
			AnchorPoint = v2New(0.5, 0),
			Position = fromScale(-0.52, 0),
			Size = fromScale(0.94, 1),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTransparency = 0.4,

			Text = Computed(scope, function(use)
				return "Lv." .. use(self.playerData.Levels)
			end),
			Visible = Computed(scope, function(use)
				if id == "DEF" then
					return if use(self.charStatsDict.DEF[2]) <= 0 then false else true
				elseif id == "HP" then
					return if use(self.charStatsDict.DEF[2]) > 0 then false else true
				end
			end),
		})
	end

	local function exCategoryOpened()
		isSelecting:set(false)
	end
	Signals.ExCategoryOpened:Connect(exCategoryOpened)

	return Fusion.New(scope, "Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		BackgroundColor3 = color3New(),

		Size = Tween(scope, Fusion.Computed(scope, function(use)
			if id == "MP" then
				return if use(self.charStatsDict.DEF[2]) > 0 then fromScale(0.15, 0.875) else fromScale(0.2, 0.875)
			elseif id == "DEF" then
				return if use(self.charStatsDict.DEF[2]) <= 0 then fromScale(0, 0.875) else fromScale(0.15, 0.875)
			else
				return fromScale(0.2, 0.875)
			end
		end), AssetBook.TweenInfos.half),
		Visible = Computed(scope, function(use)
			if id == "DEF" then
				return if use(self.charStatsDict.DEF[2]) > 0 then true else false
			else
				return true
			end
		end),

		[Fusion.Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 2.5,
				Enabled = true,

				Transparency = Tween(scope, Computed(scope, function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Fusion.New(scope, "Frame")({
				Name = "Bar",
				ZIndex = 0,

				Size = Tween(scope, Computed(scope, function(use)
					local x = clamp(use(self.charStatsDict[id][1]) / use(self.charStatsDict[id][2]), 0, 1)

					return fromScale(x, 1)
				end), AssetBook.TweenInfos.halfBack),

				BackgroundColor3 = Tween(scope, Computed(scope, function(use)
					if id == "HP" then
						if use(self.charStatsDict.HPHealing) then
							return colors.DEFRepairing
						end

						local HP, maxHP = use(self.charStatsDict[id][1]) :: number, use(self.charStatsDict[id][2]) :: number

						if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
							return colors.HPMid
						elseif HP / maxHP <= 0.33 then
							return colors.HPLow
						else
							return colors.HP
						end
					elseif id == "DEF" then
						return if use(self.charStatsDict.DEFRepairing) then colors.DEFRepairing else colors.DEF
					else
						return colors[id]
					end
				end), AssetBook.TweenInfos.onceHalf),

				[Fusion.Children] = { Components.RoundUICorner(scope) },
			}),
			Components.HoverImageButton(scope, {
				ZIndex = 2,

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
			}),
			Components.TextLabel(scope, {
				Name = "Stat",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0),
				Size = fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextStrokeTransparency = 0.7,

				Text = Computed(scope, function(use)
					return use(self.charStatsDict[id][1]) .. "/" .. use(self.charStatsDict[id][2])
				end),
			}),
			Components.TextLabel(scope, {
				Name = "Title",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0),
				Size = fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextStrokeTransparency = 0.7,
				Text = names[id],
			}),

			children
		},
	})
end

return StatBar
