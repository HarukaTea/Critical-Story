--!strict

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new
local clamp = math.clamp

local function ProgressCircle(direction: string, self: table, slot: number) : Frame
    return Components.Frame({
		Name = "ProgressCircle"..direction,
		ClipsDescendants = true,
		AnchorPoint = v2New(),
		Position = if direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
		Size = fromScale(0.5, 1),
		ZIndex = 2,
		Visible = Fusion.Computed(function(use)
			return if use(self.activeCDRotationList[slot]) > 0 then true else false
		end),

		[Fusion.Children] = {
			Components.ImageLabel({
				Name = "ProgressImage",
				Position = if direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
				Size = fromScale(2, 1),
				Image = "rbxasset://textures/ui/Controls/RadialFill.png",

				[Fusion.Children] = {
					Fusion.New("UIGradient")({
						Rotation = Fusion.Computed(function(use)
							local angle = clamp(use(self.activeCDRotationList[slot]) * 360, 0, 360)

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

return ProgressCircle