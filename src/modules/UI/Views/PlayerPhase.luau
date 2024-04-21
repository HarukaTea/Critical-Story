--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerPhasePlrBar = require(RepS.Modules.UI.Components.PlayerPhasePlrBar)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new

local function PlayerPhase(self: table) : Frame
    self.playersInCombat = {}
    
    return Components.Frame({
        Name = "PlayerPhase",
        AnchorPoint = v2New(),
        Position = fromScale(-0.015, -0.5),

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.4, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(self.playersInCombat, function(use, plr: ObjectValue)
                return PlayerPhasePlrBar(plr.Value, self)
            end)
        }
    })
end

return PlayerPhase
