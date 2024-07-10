--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children = Fusion.Children

local fromScale = UDim2.fromScale

local function ItemCostFrame(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    return Components.Frame(scope, {
        Name = "Stats",
        Position = fromScale(0.853, 0.572),
        Size = fromScale(0.25, 0.651),

        [Children] = {
            Fusion.New(scope, "UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0.05, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Components.TextBox(scope, {
                Name = "BuyAmount",
                Size = fromScale(0.5, 0.075),

                [Fusion.Out("Text")] = self.buyAmount,

                Text = Fusion.Computed(scope, function(use)
                    return use(self.buyAmount)
                end),

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "ItemCost",
                Size = fromScale(0.9, 0.075),
                TextScaled = false,

                Text = Fusion.Computed(scope, function(use)
                    local totalCost = use(self.itemCost) :: number

                    --- amount check
                    local amount = tonumber(use(self.buyAmount)) :: string
                    if amount then
                        local check = HarukaLib:TypeCheck("MinMax", amount, 0, 99999)
                        local check2 = HarukaLib:TypeCheck("Integer", amount)

                        if not check or not check2 then
                            return "COST ??? GOLD"
                        end
                    else
                        return "COST ??? GOLD"
                    end

                    totalCost *= amount

                    return "COST "..HarukaLib:NumberConvert(totalCost, "%.2f").." GOLD"
                end),
                TextColor3 = Fusion.Computed(scope, function(use)
                    return use(self.itemCostColor)
                end),
                TextSize = Fusion.Computed(scope, function(use)
                    return use(self.absStatSize) - 3
                end)
            })
        }
    })
end

return ItemCostFrame
