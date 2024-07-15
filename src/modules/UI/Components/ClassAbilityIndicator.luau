--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp

local function ClassAbilityIndicator(self: table) : Frame
    local scope = self.scope :: Fusion.Scope

    local charClassInfo = self.charClassInfo :: table

    return Fusion.Computed(scope, function(use: Fusion.Use, localScope: Fusion.Scope)
        local class = use(self.playerData.Class) :: string
        if class == nil then return nil end

        --- other classes that don't need indicators
        local blackList = { "Repeater", "Striker", "Alchemist" }
        if table.find(blackList, class) then return nil end

        return Components.Frame(localScope, {
            Name = class.."Style",
            Position = fromScale(0.5, 1.85),
            Visible = Computed(localScope, function(localUse: Fusion.Use)
                --- in combat condition
                if localUse(self.charStatsDict.IsInCombat)
                    and localUse(self.playerData.Class) == class
                    and localUse(self.charClassInfo[class]) > 0 then

                    return true
                end

                return false
            end),

            [Children] = {
                Components.Frame(localScope, {
                    AnchorPoint = v2New(),
                    Name = "BarBG",
                    BackgroundTransparency = 0,
                    Position = fromScale(0.06, 0.383),
                    Size = fromScale(0.25, 0.2),

                    [Children] = {
                        Components.RoundUICorner(localScope),
                        Components.Frame(localScope, {
                            Name = "TweenBar",
                            BackgroundColor3 = AssetBook.ClassInfo[class].Color,
                            BackgroundTransparency = 0,

                            Size = Fusion.Tween(localScope, Computed(localScope, function(localUse: Fusion.Use)
                                if class == "Warrior" then
                                    return fromScale(0, 1)

                                elseif class == "Archer" then
                                    local x = clamp(localUse(charClassInfo.Archer) / 10, 0, 1)

                                    return fromScale(x, 1)

                                else
                                    local x = clamp(localUse(charClassInfo[class]) / 100, 0, 1)

                                    return fromScale(x, 1)
                                end
                            end), AssetBook.TweenInfos.twiceHalf),

                            [Children] = { Components.RoundUICorner(localScope) }
                        })
                    }
                }),
                Components.TextLabel(localScope, {
                    Name = "Amount",
                    Position = fromScale(0.06, -0.425),
                    Size = fromScale(0.25, 0.6),

                    Text = Fusion.Computed(localScope, function(localUse: Fusion.Use)
                        if class == "Warrior" then
                            return "COMBO x"..localUse(self.charClassInfo.Warrior)

                        elseif class == "Archer" then
                            local arrows = localUse(self.charClassInfo.Archer) :: string

                            return if arrows == 1 then "1 ARROW" else arrows.." ARROWS"

                        elseif class == "Wizard" then
                            return "FOCUS "..localUse(self.charClassInfo.Wizard).."%"

                        elseif class == "Knight" then
                            return "GUARD "..localUse(self.charClassInfo.Knight).."%"

                        elseif class == "Rogue" then
                            return localUse(self.charClassInfo.Rogue).."% CHANCE"

                        elseif class == "Juggernaut" then
                            return "RAGE "..localUse(self.charClassInfo.Juggernaut).."%"

                        elseif class == "Reaper" then
                            return localUse(self.charClassInfo.Reaper).."% LIFE STOLEN"
                        end
                    end),
                    TextColor3 = AssetBook.ClassInfo[class].Color,

                    [Children] = { Components.TextUIStroke(localScope, { Thickness = 2 }) }
                })
            }
        })
    end)
end

return ClassAbilityIndicator
