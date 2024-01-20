--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.HarukaFrameworkClient).Fusion

local PlayerEffect = require(RepS.Modules.UI.Components.PlayerEffect)

local v2New = Vector2.new
local udNew =  UDim.new
local fromScale = UDim2.fromScale
local sFind = string.find

local function PlayerEffectsFrame(direction: string, self: table) : Frame
    return Components.Frame({
        Name = "Effects"..direction,
        AnchorPoint = v2New(),
        Position = if direction == "Left" then fromScale(-0.234, -0.957) else fromScale(0.72, -0.957),
        Size = fromScale(0.5, 0.78),

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.03, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = if direction == "Left" then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Left,
            }),
            Fusion.ForValues(self.charStatsDict.EffectsList, function(use, effect)
                local effectInfo = {
                    Script = effect,
                    Duration = Fusion.Value(effect:GetAttribute("Duration")),
                }

                if direction == "Left" and sFind(effect.Name, "Buff") then
                    return PlayerEffect(effect.Name, effectInfo)

                elseif direction == "Right" and sFind(effect.Name, "Debuff") then
                    return PlayerEffect(effect.Name, effectInfo)
                end
            end, Fusion.cleanup)
        }
    })
end

return PlayerEffectsFrame
