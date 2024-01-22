--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new

local IMAGES = {
    AttackBuff = "rbxassetid://2970818097"
}

local function mapValue(val: number, duration: number) : number
    --- you may be confused about this math problem, well, I'm confused too lol
    local from = (val - 0) / (duration - 0)
    local to = from * (1 - 0) + 0

    return to
end

local function ProgressCircle(direction: string, info: table) : Frame
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
        Size = fromScale(0.199, 1),
        Image = IMAGES[effect],

        [Children] = {
            Components.RoundUICorner(),
            Components.Frame({
                Name = "Shadow",
                BackgroundTransparency = 0.6,

                [Children] = { Components.RoundUICorner() }
            }),

            ProgressCircle("Left", info),
            ProgressCircle("Right", info)
        }
    })
end

return PlayerEffect