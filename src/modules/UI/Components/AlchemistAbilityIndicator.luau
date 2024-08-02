--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClassBook = require(RepS.Modules.Data.ClassBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local fromScale = UDim2.fromScale

local function AlchemistAbilityIndicator(self: table) : Frame
    local scope = self.scope :: Fusion.Scope
    local creations = self.char.AlchemistCreations :: Folder

    local function _handleCreations()
        task.wait()
        self.charClassInfo.Alchemist:set(creations:GetChildren())
    end
    _handleCreations()
    table.insert(scope, creations.ChildAdded:Connect(_handleCreations))
    table.insert(scope, creations.ChildRemoved:Connect(_handleCreations))

    return Fusion.Computed(scope, function(use: Fusion.Use, localScope: Fusion.Scope)
        local class = use(self.playerData.Class) :: string
        if class ~= "Alchemist" then return nil end

        return Components.Frame(localScope, {
            Name = "AlchemistStyle",
            Position = fromScale(0.5, 1.85),

            Visible = Fusion.Computed(localScope, function(localUse: Fusion.Use)
                --- in combat condition
                if localUse(self.charStatsDict.IsInCombat)
                    and localUse(self.playerData.Class) == "Alchemist"
                    and localUse(self.charClassInfo.Alchemist)[1] then

                    return true
                end

                return false
            end),

            [Fusion.Children] = {
                Components.Frame(localScope, {
                    Name = "Creations",
                    AnchorPoint = Vector2.new(),
                    Position = fromScale(0.06, -0.425),
                    Size = fromScale(0.25, 0.6),

                    [Fusion.Children] = {
                        Fusion.New(localScope, "UIListLayout")({
                            Padding = UDim.new(),
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center
                        }),

                        Fusion.ForValues(localScope, self.charClassInfo.Alchemist, function(_, _, creation: BoolValue)
                            local creationList = {
                                Red = Color3.fromRGB(255, 85, 127),
                                Green = Color3.fromRGB(0, 255, 22),
                                Blue = Color3.fromRGB(85, 255, 255)
                            }

                            return Components.TextLabel(localScope, {
                                Name = creation.Name,
                                Size = fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Text = string.sub(creation.Name, 1, 1),
                                TextColor3 = creationList[creation.Name],

                                [Fusion.Children] = { Components.TextUIStroke(localScope, { Thickness = 2 }) }
                            })
                        end)
                    }
                }),

                Components.Frame(localScope, {
                    AnchorPoint = Vector2.new(),
                    Name = "BarBG",
                    BackgroundTransparency = 0,
                    Position = fromScale(0.06, 0.383),
                    Size = fromScale(0.25, 0.2),

                    [Fusion.Children] = {
                        Components.RoundUICorner(localScope),
                        Components.Frame(localScope, {
                            Name = "TweenBar",
                            BackgroundColor3 = ClassBook.ClassInfo.Alchemist.Color,
                            BackgroundTransparency = 0,

                            Size = Fusion.Tween(localScope, Fusion.Computed(localScope, function(localUse: Fusion.Use)
                                return fromScale(#localUse(self.charClassInfo.Alchemist) / 3, 1)
                            end), AssetBook.TweenInfos.twiceHalf),

                            [Fusion.Children] = { Components.RoundUICorner(localScope) }
                        }),
                    }
                }),
            }
        })
    end)
end

return AlchemistAbilityIndicator
