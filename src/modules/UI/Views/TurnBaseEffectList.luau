--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local EffectIndicator = require(RepS.Modules.UI.Components.EffectIndicator)

local fromScale = UDim2.fromScale
local udNew = UDim.new
local v2New = Vector2.new

local function TurnBaseEffectList(id: string, info: table) : Frame
    return Components.Frame({
        Name = id.."EffectsList",
        AnchorPoint = v2New(),
        Position = fromScale(0, -0.55),
        Size = fromScale(1, 0.5),

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = if id == "Player" then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal
            }),

            Fusion.ForValues(info.EffectsList, function(_, effect: Script)
                return EffectIndicator(effect)
            end, Fusion.cleanup)
        }
    })
end

return TurnBaseEffectList
