--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ActionPanel = require(RepS.Modules.UI.Views.ActionPanel)
local MobPhase = require(RepS.Modules.UI.Views.MobPhase)
local PlayerPhase = require(RepS.Modules.UI.Views.PlayerPhase)

local Children, New = Fusion.Children, Fusion.New

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new

return function (plr: Player)
    local self = setmetatable({}, TurnBaseUI)

    self.plr = plr

    Components.ScreenGui({
        Name = "TurnBasedUI",
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame({
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Position = fromScale(0.5, 1),
				Size = fromScale(1, 0.1),
				ZIndex = 2,
				Visible = false,

                [Children] = {
                    New("UIAspectRatioConstraint")({ AspectRatio = 25.836 }),

                    ActionPanel(self),
                    MobPhase(self),
                    PlayerPhase(self),

                    Components.Frame({
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.42),

						[Children] = {
							New("UIListLayout")({
								Padding = udNew(0.01, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
						},
					}),
                }
            })
        }
    })
end