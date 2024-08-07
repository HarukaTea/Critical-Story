--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)
local StatusEffectBook = require(RepS.Modules.Data.StatusEffectBook)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new
local wait = task.wait

local function ProgressCircle(direction: string, effect: Script, info: table) : Frame
    return Components.Frame(info[2], {
		Name = "ProgressCircle"..direction,
		ClipsDescendants = true,
		AnchorPoint = v2New(),
		Position = if direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
		Size = fromScale(0.5, 1),
		ZIndex = 2,

		[Children] = {
			Components.ImageLabel(info[2], {
				Name = "ProgressImage",
				Position = if direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
				Size = fromScale(2, 1),
				Image = "rbxasset://textures/ui/Controls/RadialFill.png",
                ImageColor3 = StatusEffectBook.BuffInfo[effect.Name].Color,

				[Children] = {
					Fusion.New(info[2], "UIGradient")({
						Rotation = Fusion.Computed(info[2], function(use: Fusion.Use)
							local angle = clamp(use(info[1]) * 360, 0, 360)

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

local function EffectIndicator(effect: Script, scope: Fusion.Scope) : ImageLabel
	local maxDuration = effect:GetAttribute("MaxDuration") or 0.1
	local percentage = Fusion.Value(scope, 1)
	Spawn(function()
		for _ = maxDuration, 0.1, -0.1 do
			percentage:set(Fusion.peek(percentage) - 1/(maxDuration * 10))
			wait(0.1)
		end
	end)

    return Components.ImageLabel(scope, {
        Name = effect.Name,
        BackgroundTransparency = 0,
        Size = fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = StatusEffectBook.BuffInfo[effect.Name].Icon,

        [Children] = {
            Components.RoundUICorner(scope),

            ProgressCircle("Left", effect, { percentage, scope }),
            ProgressCircle("Right", effect, { percentage, scope }),

			Components.TextLabel(scope, {
				Name = "Power",
				AnchorPoint = v2New(0.5, 0),
				Position = fromScale(0.5, 0.6),
				Size = fromScale(1.2, 0.5),
				ZIndex = 3,

				Text = Fusion.Computed(scope, function()
					if effect:GetAttribute("Power") then return effect:GetAttribute("Power").."x" end
					if effect:GetAttribute("Percentage") then return effect:GetAttribute("Percentage").."%" end
				end),

				[Children] = {
					Components.TextUIStroke(scope, { Thickness = 2.5 })
				}
			}),
			Components.Frame(scope, {
                Name = "Shadow",
                BackgroundTransparency = 0.6,

                [Children] = { Components.RoundUICorner(scope) }
            })
        }
    })
end

return EffectIndicator