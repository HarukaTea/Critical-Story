--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function PointsCenterPanel(self: table) : Frame
    local scope = self.scope :: Fusion.Scope
    
    return Components.Frame(scope, {
        Name = "Points",

        Visible = Computed(scope, function(use: Fusion.Use)
            return use(self.panelFilterFrames.Character.Points)
        end),

        [Children] = {
            Fusion.New(scope, "UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = udNew(0.03, 0)
            }),

            Components.TextLabel(scope, {
                Name = "Tip",
                Size = fromScale(1, 0.07),
                Text = "SKILL POINTS PER ADD",
                TextColor3 = fromRGB(255, 255, 0),
                TextXAlignment = Enum.TextXAlignment.Right,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2 })
                }
            }),
            Components.TextBox(scope, {
                Name = "PerAdd",
                Size = fromScale(0.45, 0.08),
                PlaceholderText = "POINTS HERE",

                Text = Computed(scope, function(use: Fusion.Use)
                    return use(self.pointsPerAdd)
                end),
                [Fusion.Out("Text")] = self.pointsPerAdd,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Fusion.New(scope, "UIPadding")({
                        PaddingBottom = udNew(0.05, 0),
                        PaddingTop = udNew(0.05, 0)
                    })
                }
            })
        }
    })
end

return PointsCenterPanel
