--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local EffectIndicator = require(RepS.Modules.UI.Components.EffectIndicator)

local v2New = Vector2.new
local udNew =  UDim.new
local fromScale = UDim2.fromScale
local wait = task.wait

local function PlayerEffectsList(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    local function _setEffectsChildren()
		wait()
		self.charStatsDict.EffectsList:set(self.charData.EffectsList:GetChildren())
	end
    _setEffectsChildren()
    table.insert(scope, self.charData.EffectsList.ChildAdded:Connect(_setEffectsChildren))
    table.insert(scope, self.charData.EffectsList.ChildRemoved:Connect(_setEffectsChildren))

    return Components.Frame(scope, {
        Name = "EffectsFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -1.5),
        Size = fromScale(1, 0.78),

        [Fusion.Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0.01, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal
            }),
            Fusion.ForValues(scope, self.charStatsDict.EffectsList, function(_, localScope: Fusion.Scope, effect: Script)
                return EffectIndicator(effect, localScope)
            end)
        }
    })
end

return PlayerEffectsList
