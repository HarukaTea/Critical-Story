--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local EffectIndicator = require(RepS.Modules.UI.Components.EffectIndicator)

local fromScale = UDim2.fromScale
local udNew = UDim.new
local v2New = Vector2.new

local function MonsterEffectList(info: table, self: table) : Frame
    local scope = self.scope

    return Components.Frame(scope, {
        Name = "MonsterEffectsList",
        AnchorPoint = v2New(),
        Position = fromScale(0, -0.55),
        Size = fromScale(1, 0.5),

        [Fusion.Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal
            }),

            Fusion.ForValues(scope, info.EffectsList, function(_, localScope: table, effect: Script)
                return EffectIndicator(effect, localScope)
            end)
        }
    })
end

return MonsterEffectList
