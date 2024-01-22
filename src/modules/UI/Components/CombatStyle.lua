--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp

local function CombatStyle(self: table, class: string) : Frame
    return Components.Frame({
        Name = class.."Style",
        Visible = Computed(function(use)
            local neededClass = use(self.charStatsDict.PlayerData.Class)
            local inCombat = use(self.charStatsDict.IsInCombat)

            --- in combat condition
            if inCombat then
                if neededClass == class and use(self.charClassInfo[neededClass].Val) > 0 then
                    return true
                end

                return false
            end

            return false
        end),
        [Fusion.Ref] = self.charClassInfo[class].UI,

        [Children] = {
            Components.Frame({
                AnchorPoint = v2New(),
                Name = "BarBG",
                BackgroundTransparency = 0,
                Position = fromScale(0.06, 0.383),
                Size = fromScale(0.25, 0.2),

                [Children] = {
                    Components.RoundUICorner(),
                    Components.Frame({
                        Name = "Bar",
                        BackgroundColor3 = AssetBook.ClassInfo[class].Color,
                        Size = fromScale(1, 1),
                        BackgroundTransparency = 0,
                        Visible = Computed(function(use)
                            local neededClass = use(self.charStatsDict.PlayerData.Class)

                            return if neededClass == "Warrior" and class == "Warrior" then true else false
                        end),

                        [Children] = { Components.RoundUICorner() }
                    }),
                    Components.Frame({
                        Name = "TweenBar",
                        BackgroundColor3 = AssetBook.ClassInfo[class].Color,
                        Size = Fusion.Tween(Fusion.Computed(function(use)
                            if class == "Archer" then
                                local x = clamp(use(self.charClassInfo.Archer.Val) / 10, 0, 1)

                                return fromScale(x, 1)

                            elseif class == "Wizard" then
                                local x = clamp(use(self.charClassInfo.Wizard.Val) / 100, 0, 1)

                                return fromScale(x, 1)

                            elseif class == "Knight" then
                                local x = clamp(use(self.charClassInfo.Knight.Val) / 100, 0, 1)

                                return fromScale(x, 1)

                            elseif class == "Rogue" then
                                local x = clamp(use(self.charClassInfo.Rogue.Val) / 100, 0, 1)

                                return fromScale(x, 1)
                            end

                            return fromScale(0, 0)
                        end), AssetBook.TweenInfos.half),
                        BackgroundTransparency = 0,
                        Visible = Computed(function(use)
                            local neededClass = use(self.charStatsDict.PlayerData.Class)

                            return if neededClass == "Warrior" and class == "Warrior" then false else true
                        end),

                        [Children] = { Components.RoundUICorner() }
                    })
                }
            }),
            Components.TextLabel({
                Name = "Amount",
                Position = fromScale(0.06, -0.425),
                Size = fromScale(0.25, 0.6),
                Text = Fusion.Computed(function(use)
                    if class == "Warrior" then
                        return "COMBO x"..use(self.charClassInfo.Warrior.Val)

                    elseif class == "Archer" then
                        local arrows = use(self.charClassInfo.Archer.Val)

                        if arrows == 1 then
                            return "1 ARROW"
                        else
                            return arrows.." ARROWS"
                        end

                    elseif class == "Wizard" then
                        return "CASTED "..use(self.charClassInfo.Wizard.Val).."%"

                    elseif class == "Knight" then
                        return "GUARD "..use(self.charClassInfo.Knight.Val).."%"

                    elseif class == "Rogue" then
                        return "CRITICAL "..use(self.charClassInfo.Rogue.Val).."%"
                    end
                end),
                TextColor3 = AssetBook.ClassInfo[class].Color,

                [Children] = { Components.TextUIStroke({ Thickness = 2.5 }) }
            })
        }
    })
end

return CombatStyle
