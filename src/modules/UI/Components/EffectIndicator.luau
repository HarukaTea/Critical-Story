--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new

local function mapValue(val: number, duration: number) : number
    --- you may be confused about this math problem, well, I'm confused too lol
    local from = (val - 0) / (duration - 0)
    local to = from * (1 - 0) + 0

    return to
end

local function ProgressCircle(direction: string, effect: Script, info: table) : Frame
    return Components.Frame(info[3], {
		Name = "ProgressCircle"..direction,
		AnchorPoint = v2New(),
		Position = if direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
		Size = fromScale(0.5, 1),
		ZIndex = 2,

		[Children] = {
			Components.ImageLabel(info[3], {
				Name = "ProgressImage",
				Position = if direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
				Size = fromScale(2, 1),
				Image = "rbxasset://textures/ui/Controls/RadialFill.png",
                ImageColor3 = AssetBook.BuffInfo[effect.Name].Color,

				[Children] = {
					Fusion.New(info[3], "UIGradient")({
						Rotation = Fusion.Computed(info[3], function(use)
                            local mappedDuration = mapValue(use(info[1]), info[2])
							local angle = clamp(mappedDuration * 360, 0, 360)

							return if direction == "Left" then clamp(angle, 180, 360) else clamp(angle, 0, 180)
						end),
						Transparency = nsNew({
							nsKPNew(0, 0, 0),
							nsKPNew(0.499, 0, 0), nsKPNew(0.5, 1, 0),
							nsKPNew(1, 1, 0)
						})
					})
				}
			})
		}
	})
end

local function EffectIndicator(effect: Script, scope: table) : ImageLabel
	local maxTurn = 0
	local turn = Fusion.Value(scope, effect:GetAttribute("Turn"))

	HarukaLib:Hydrate(effect, {
		["Attr-Turn"] = function(newTurn: number)
			if newTurn >= maxTurn then maxTurn = newTurn end

			turn:set(newTurn)
		end
	})

    return Components.ImageLabel(scope, {
        Name = effect.Name,
        BackgroundTransparency = 0,
        Size = fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = AssetBook.BuffInfo[effect.Name].Icon,

        [Children] = {
            Components.RoundUICorner(scope),

            ProgressCircle("Left", effect, { turn, maxTurn, scope }),
            ProgressCircle("Right", effect, { turn, maxTurn, scope }),

			Components.TextLabel(scope, {
				Name = "Power",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0.6),
				Size = fromScale(1.2, 0.5),
				ZIndex = 3,

				Text = Fusion.Computed(scope, function(use)
					return use(turn)
				end),

				[Children] = {
					Components.TextUIStroke(scope, { Thickness = 2.5 })
				}
			})
        }
    })
end

return EffectIndicator