--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Computed, Value, AttributeChange, Tween =
	Fusion.New, Fusion.Computed, Fusion.Value, Fusion.AttributeChange, Fusion.Tween

local color3New, v2New = Color3.new, Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp

local NAMES = { DEF = "SHIELD", TP = "TP" }
local COLORS = {
	DEF = fromRGB(167, 115, 56),
    TP = fromRGB(73, 67, 167),
}
local STROKES_TRANS = {
	DEF = Value(1),
    TP = Value(1)
}

local function TurnBaseStatBar(id: string, self: table) : Frame
	local char = self.char :: Model
	self.charStatsDict = {
		Shield = Value(char:GetAttribute("Shield")),
		MaxShield = Value(char:GetAttribute("MaxShield")),
		TP = Value(char:GetAttribute("TP"))
	}
	local charStatsDict = self.charStatsDict

	Fusion.Hydrate(char)({
		[AttributeChange("Shield")] = function(newShield: number)
			charStatsDict.Shield:set(newShield)
		end,
		[AttributeChange("MaxShield")] = function(newShield: number)
			charStatsDict.MaxShield:set(newShield)
		end,
		[AttributeChange("TP")] = function(newTP: number)
			charStatsDict.TP:set(newTP)
		end
	})

    return New("Frame")({
		Name = id,
		AnchorPoint = v2New(0.5, 0),
		Size = fromScale(0.175, 0.875),
		BackgroundColor3 = color3New(),

		[Fusion.Children] = {
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
				ZIndex = 0,
				BackgroundColor3 = COLORS[id],

				Size = Tween(Computed(function(use)
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
					STROKES_TRANS[id]:set(0)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
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
					if id == "DEF" then
						return use(charStatsDict.Shield) .. "/" ..use(charStatsDict.MaxShield)

					elseif id == "TP" then
						return use(charStatsDict.TP) .. "/100"
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
