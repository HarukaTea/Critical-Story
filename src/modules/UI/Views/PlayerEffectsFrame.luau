--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerEffect = require(RepS.Modules.UI.Components.PlayerEffect)

local v2New = Vector2.new
local udNew =  UDim.new
local fromScale = UDim2.fromScale

local function PlayerEffectsFrame(self: table) : Frame
    return Components.Frame({
        Name = "EffectsFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -1.5),
        Size = fromScale(1, 0.78),

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.01, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal
            }),
            Fusion.ForValues(self.charStatsDict.EffectsList, function(use, effect: Script)
                local effectInfo = {
                    Script = effect,
                    Duration = Fusion.Value(effect:GetAttribute("Duration")),
                    Power = effect:GetAttribute("Power")
                }

                return PlayerEffect(effect.Name, effectInfo)
            end, Fusion.cleanup)
        }
    })
end

return PlayerEffectsFrame
