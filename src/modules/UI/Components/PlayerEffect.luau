--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

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

local function ProgressCircle(direction: string, effect: string, info: table) : Frame
    local maxDuration = 0

    Fusion.Hydrate(info.Script)({
        [Fusion.AttributeChange("Duration")] = function(newDuration)
            if newDuration > maxDuration then maxDuration = newDuration end

            info.Duration:set(newDuration)
        end
    })

    return Components.Frame({
		Name = "ProgressCircle"..direction,
		ClipsDescendants = true,
		AnchorPoint = v2New(),
		Position = if direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
		Size = fromScale(0.5, 1),
		ZIndex = 2,

		[Children] = {
			Components.ImageLabel({
				Name = "ProgressImage",
				Position = if direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
				Size = fromScale(2, 1),
				Image = "rbxasset://textures/ui/Controls/RadialFill.png",
                ImageColor3 = AssetBook.BuffColors[effect],

				[Children] = {
					Fusion.New("UIGradient")({
						Rotation = Fusion.Computed(function(use)
                            local mappedDuration = mapValue(use(info.Duration), maxDuration)
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

local function PlayerEffect(effect: string, info: table) : ImageLabel
    return Components.ImageLabel({
        Name = effect,
        BackgroundTransparency = 0,
        Size = fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = AssetBook.BuffImages[effect],

        [Children] = {
            Components.RoundUICorner(),
            Components.Frame({
                Name = "Shadow",
                BackgroundTransparency = 0.6,

                [Children] = { Components.RoundUICorner() }
            }),
            Components.TextLabel({
                Name = "BuffPower",
                Position = fromScale(0, 0.6),
                Size = fromScale(1, 0.5),
                ZIndex = 3,
                Text = info.Power.."x",

                [Children] = {
                    Components.TextUIStroke({ Thickness = 3 })
                }
            }),

            ProgressCircle("Left", effect, info),
            ProgressCircle("Right", effect, info)
        }
    })
end

return PlayerEffect