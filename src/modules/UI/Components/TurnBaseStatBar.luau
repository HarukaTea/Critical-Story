--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Computed = Fusion.Computed

local color3New, v2New = Color3.new, Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp

local function TurnBaseStatBar(id: string, self: table) : Frame
	local NAMES = { DEF = "SHIELD", TP = "TP" }
	local COLORS = {
		DEF = fromRGB(167, 115, 56),
		TP = fromRGB(73, 67, 167),
	}
	local isSelecting = Fusion.Value(false)
	local charStatsDict = self.charStatsDict

    return Fusion.New("Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		Size = fromScale(0.175, 0.875),
		BackgroundColor3 = color3New(),

		[Fusion.Children] = {
			Components.RoundUICorner(),
			Components.UIStroke({
				Thickness = 2.5,
				Enabled = true,

				Transparency = Fusion.Tween(Computed(function(use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Fusion.New("Frame")({
				Name = "Bar",
				ZIndex = 0,
				BackgroundColor3 = COLORS[id],

				Size = Fusion.Tween(Computed(function(use)
					if id == "DEF" then
						local x = clamp(use(charStatsDict.Shield) / use(charStatsDict.MaxShield), 0, 1)

						return fromScale(x, 1)

					elseif id == "TP" then
						local x = clamp(use(charStatsDict.TP) / 100, 0, 1)

						return fromScale(x, 1)
					end
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
					if id == "DEF" then
						return use(charStatsDict.Shield) .. "/" ..use(charStatsDict.MaxShield)

					elseif id == "TP" then
						return use(charStatsDict.TP) .. "%"
					end
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
			})
		},
	})
end

return TurnBaseStatBar
