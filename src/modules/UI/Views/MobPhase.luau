--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local MobPhaseMobBar = require(RepS.Modules.UI.Components.MobPhaseMobBar)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new

local function MobPhase(self: table) : Frame
    self.targetingMobs = {}

    return Components.Frame({
        Name = "MobPhase",
        AnchorPoint = v2New(),
        Position = fromScale(0.015, -0.5),

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.4, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(self.targetingMobs, function(use, mob: ObjectValue)
                return MobPhaseMobBar(mob.Value, self)
            end)
        }
    })
end

return MobPhase
