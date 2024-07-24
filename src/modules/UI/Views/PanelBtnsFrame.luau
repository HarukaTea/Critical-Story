--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ExCategoryOpenBtn = require(RepS.Modules.UI.Components.ExCategoryOpenBtn)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function PanelBtnsFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
        Name = "PanelBtnsFrame",
        Position = fromScale(0.5, 0),
		Size = fromScale(1, 1.1),

        [Children] = {
            Components.Frame(scope, {
                Name = "ExCategoryFrame",
                AnchorPoint = v2New(),
                Position = fromScale(0.837, 0),
                Size = fromScale(0.15, 0.8),

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = UDim.new(0.08, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right
                    }),

                    ExCategoryOpenBtn("Menu", self),
                    ExCategoryOpenBtn("Backpack", self)
                }
            }),
        },
    })
end

return PanelBtnsFrame
