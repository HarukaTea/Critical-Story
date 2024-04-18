--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed, Value, AttributeChange =
    Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.AttributeChange

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp
local wait = task.wait

local function CombatStyle(self: table, class: string) : Frame
    local charClassInfo = self.charClassInfo

    Fusion.Hydrate(self.char)({
		[AttributeChange("Combo")] = function(combo)
			if combo <= 0 then
				charClassInfo.Warrior.Val:set(combo)
				return
			end

			local tagUI = Fusion.peek(charClassInfo.Warrior.UI)

			charClassInfo.Warrior.Val:set(combo)

			TS:Create(tagUI.BarBG.Bar, AssetBook.TweenInfos.twiceHalf, { Size = fromScale(1, 1) }):Play()
			wait(0.2)
			TS:Create(tagUI.BarBG.Bar, AssetBook.TweenInfos.threeHalfOne, { Size = fromScale(0, 1) }):Play()
		end,
		[AttributeChange("Arrows")] = function(arrows)
			charClassInfo.Archer.Val:set(arrows)
		end,
		[AttributeChange("WizardCasted")] = function(casted)
			charClassInfo.Wizard.Val:set(casted)
		end,
		[AttributeChange("Guard")] = function(guarded)
			charClassInfo.Knight.Val:set(guarded)
		end,
		[AttributeChange("RogueCritical")] = function(criChance)
			charClassInfo.Rogue.Val:set(criChance)
		end
	})

    return Components.Frame({
        Name = class.."Style",
        Position = fromScale(0.5, 1.85),
        Visible = Computed(function(use)
            local neededClass = use(self.playerData.Class) :: string
            local inCombat = use(self.charStatsDict.IsInCombat) :: boolean

            --- in combat condition
            if inCombat and neededClass == class and use(self.charClassInfo[neededClass].Val) > 0 then
                return true
            end

            return false
        end),
        [Fusion.Ref] = charClassInfo[class].UI,

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
                        Size = fromScale(0, 0),
                        BackgroundTransparency = 0,
                        Visible = Computed(function(use)
                            local neededClass = use(self.playerData.Class) :: string

                            return if neededClass == "Warrior" and class == "Warrior" then true else false
                        end),

                        [Children] = { Components.RoundUICorner() }
                    }),
                    Components.Frame({
                        Name = "TweenBar",
                        BackgroundColor3 = AssetBook.ClassInfo[class].Color,
                        Size = Fusion.Tween(Computed(function(use)
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
                            local neededClass = use(self.playerData.Class) :: string

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
                        local arrows = use(self.charClassInfo.Archer.Val) :: string

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
