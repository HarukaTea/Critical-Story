--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp

local function CombatStyle(self: table, class: string) : Frame
    local charClassInfo = self.charClassInfo :: table

    return Components.Frame({
        Name = class.."Style",
        Position = fromScale(0.5, 1.85),
        Visible = Computed(function(use)
            local plrClass = use(self.playerData.Class) :: string
            local inCombat = use(self.charStatsDict.IsInCombat) :: boolean

            --- in combat condition
            if inCombat and plrClass == class and use(self.charClassInfo[plrClass]) > 0 then
                return true
            end

            return false
        end),

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
                        Name = "TweenBar",
                        BackgroundColor3 = AssetBook.ClassInfo[class].Color,
                        BackgroundTransparency = 0,

                        Visible = Computed(function(use)
                            local neededClass = use(self.playerData.Class) :: string

                            return if neededClass == class then true else false
                        end),
                        Size = Fusion.Tween(Computed(function(use)
                            if class == "Warrior" then
                                if use(charClassInfo.Warrior) <= 0 then return fromScale(0, 1) end

                                return fromScale(1, 1)

                            elseif class == "Archer" then
                                local x = clamp(use(charClassInfo.Archer) / 10, 0, 1)

                                return fromScale(x, 1)

                            else
                                local x = clamp(use(charClassInfo[class]) / 100, 0, 1)

                                return fromScale(x, 1)
                            end
                        end), AssetBook.TweenInfos.twiceHalf),

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
                        return "COMBO x"..use(self.charClassInfo.Warrior)

                    elseif class == "Archer" then
                        local arrows = use(self.charClassInfo.Archer) :: string

                        return if arrows == 1 then "1 ARROW" else arrows.." ARROWS"

                    elseif class == "Wizard" then
                        return "CASTED "..use(self.charClassInfo.Wizard).."%"

                    elseif class == "Knight" then
                        return "GUARD "..use(self.charClassInfo.Knight).."%"

                    elseif class == "Rogue" then
                        return "CRITICAL "..use(self.charClassInfo.Rogue).."%"
                    end
                end),
                TextColor3 = AssetBook.ClassInfo[class].Color,

                [Children] = { Components.TextUIStroke({ Thickness = 2.5 }) }
            })
        }
    })
end

return CombatStyle
