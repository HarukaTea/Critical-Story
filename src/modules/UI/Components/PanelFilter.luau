--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udNew = UDim.new

local function PanelFilter(id: string, panelId: string, self: table): Frame
    local scope = self.scope

    return Fusion.New(scope, "Frame")({
        Name = id,
        Size = fromScale(1, 0.09),

        [Children] = {
            Components.RoundUICorner(scope),
            Fusion.New(scope, "UIGradient")({
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.7, 1),
                    NumberSequenceKeypoint.new(1, 1)
                }),

                Color = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(self.panelFilters[panelId]) == id then
                        ColorSequence.new(Color3.new(1, 1, 1)) else ColorSequence.new(Color3.new())
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Title",
                Size = fromScale(1, 1),
                Text = string.upper(id),
                TextXAlignment = Enum.TextXAlignment.Left,

                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(self.panelFilters[panelId]) == id then
                        fromRGB() else Color3.new(1, 1, 1)
                end),

                [Children] = {
                    Fusion.New(scope, "UIPadding")({
                        PaddingBottom = udNew(0.1, 0),
                        PaddingLeft = udNew(0.05, 0),
                        PaddingRight = udNew(0.05, 0),
                        PaddingTop = udNew(0.1, 0)
                    })
                }
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    self.panelFilters[panelId]:set(id)

                    for _, filter: Fusion.Value in self.panelFilterFrames[panelId] do filter:set(false) end
                    self.panelFilterFrames[panelId][id]:set(true)
                end
            })
        }
    })
end

return PanelFilter
