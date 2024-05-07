--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local TurnBaseSidePanel = require(RepS.Modules.UI.Views.TurnBaseSidePanel)

local TurnBaseAction = require(RepS.Modules.UI.Components.TurnBaseAction)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local tFind = table.find
local fromRGB = Color3.fromRGB

local function TurnBaseActionPanel(self: table) : Frame
    local scope = self.scope

    local whitelist = { "Combat", "Player" }
    local function _showPanel(phase: string)
        if not tFind(whitelist, phase) then
            self.panelPos:set(fromScale(0.5, 5))
            self.itemPanelVisible:set(false)
            self.skillPanelVisible:set(false)
            return
        end

        self.panelPos:set(fromScale(0.5, 0.5))
    end
    Events.NewPhase:Connect(_showPanel)

    return Components.Frame(scope, {
        Name = "ActionPanel",

        Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
            return use(self.panelPos)
        end), AssetBook.TweenInfos.half),

        [Children] = {
            Components.Frame(scope, {
                Name = "ImageBGCenter",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, -0.2),
                Size = fromScale(0.51, 12.9),
                BackgroundTransparency = 0,
                BackgroundColor3 = fromRGB(40, 40, 40),
                ZIndex = 0,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Enabled = true,
                        Thickness = 2.5
                    })
                }
            }),

            TurnBaseSidePanel("Items", self),
			TurnBaseSidePanel("Skills", self),

            Components.Frame(scope, {
                Name = "Actions",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, -2.3),
                Size = fromScale(0.117, 2.844),

                [Children] = {
                    Fusion.New(scope, "UIGridLayout")({
                        CellPadding = fromScale(0.1, 0.1),
                        CellSize = fromScale(0.437, 0.457),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        StartCorner = Enum.StartCorner.BottomLeft,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),

                    TurnBaseAction("Attack", self),
                    TurnBaseAction("Defend", self),
                    TurnBaseAction("Items", self),
                    TurnBaseAction("Skills", self)
                }
            })
        }
    })
end

return TurnBaseActionPanel
