--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local TurnBasedAction = require(RepS.Modules.UI.Components.TurnBasedAction)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function ActionPanel(self: table) : Frame
    return Components.Frame({
        Name = "ActionPanel",

        [Children] = {
            Components.Frame({
                Name = "ImageBG",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, -1.5),
                Size = fromScale(0.51, 12.9),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(),
                    Components.UIStroke({
                        Enabled = true,
                        Thickness = 2.5
                    })
                }
            }),
            Components.Frame({
                Name = "Actions",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, -2.3),
                Size = fromScale(0.117, 2.844),

                [Children] = {
                    Fusion.New("UIGridLayout")({
                        CellPadding = fromScale(0.1, 0.1),
                        CellSize = fromScale(0.437, 0.457)
                    }),

                    TurnBasedAction("Attack", self),
                    TurnBasedAction("Items", self),
                    TurnBasedAction("Skills", self),
                    TurnBasedAction("Defend", self)
                }
            })
        }
    })
end

return ActionPanel
