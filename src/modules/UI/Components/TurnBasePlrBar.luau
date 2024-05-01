--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Tween, Computed, New, OnEvent, Value =
    Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.New, Fusion.OnEvent, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udimNew = UDim.new
local clamp = math.clamp

local function TurnBasePlrBar(char: Model, self: table) : Frame
    local plr = Players:GetPlayerFromCharacter(char)
    local info = {
        isSelecting = Value(false),
        actionIsSelecting = Value(false),

        HP = Value(char.Humanoid.Health),
        MaxHP = Value(char.Humanoid.MaxHealth),
        NextAction = Value("")
    }

    Fusion.Hydrate(char.Humanoid)({
        [Fusion.OnChange("Health")] = function(newHP: number)
            info.HP:set(newHP)
        end,
        [Fusion.OnChange("MaxHealth")] = function(newHP: number)
            info.MaxHP:set(newHP)
        end
    })
    Fusion.Hydrate(plr)({
        [Fusion.AttributeChange("NextAction")] = function(newAction: string)
            info.NextAction:set(newAction)
        end
    })

    return Components.Frame({
        Name = char.Name,

        [Children] = {
            Components.Frame({
                Name = "Player",
                AnchorPoint = v2New(),
                BackgroundTransparency = 0,
                Size = fromScale(0.18, 1),

                Position = Tween(Computed(function(use)
                    if use(self.targetingMob) and use(self.targetingMob):FindFirstChild("TargetingList") then
                        if use(self.targetingMob).TargetingList:FindFirstChild(char.Name) then
                            return fromScale(0, 0)
                        else
                            return fromScale(-0.3, 0)
                        end
                    end
                end), AssetBook.TweenInfos.twiceHalfOne),

                [Children] = {
                    Components.RoundUICorner(),
                    Components.UIStroke({
                        Thickness = 2.7,
                        Enabled = true,

                        Transparency = Tween(Computed(function(use)
                            return if use(info.isSelecting) then 0.3 else 1
                        end), AssetBook.TweenInfos.twiceHalf)
                    }),
                    Components.ImageLabel({
                        Name = "PlayerClass",
                        Image = AssetBook.ClassInfo[plr:GetAttribute("Class")].Image,
                        Position = fromScale(0.78, 0),
                        Size = fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,

                        [Children] = { Components.RoundUICorner() }
                    }),
                    Components.TextLabel({
                        Name = "PlayerName",
                        Position = fromScale(0.117, 0.1),
                        Size = fromScale(0.634, 0.35),
                        Text = plr.DisplayName,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextColor3 = AssetBook.ClassInfo[plr:GetAttribute("Class")].Color
                    }),
                    Components.ImageLabel({
                        Name = "NextAction",
                        BackgroundTransparency = 0,
                        Position = fromScale(1.1, 0),
                        Size = fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        Image = Computed(function(use)
                            local nextAction = use(info.NextAction)

                            if nextAction == "" or nextAction == nil then
                                return AssetBook.Items.ItemImages.Null

                            elseif nextAction == "Attack" then
                                return AssetBook.ClassInfo[plr:GetAttribute("Class")].Image

                            elseif nextAction == "Items" then
                                return AssetBook.Items.ItemImages[plr:GetAttribute("NextItem")]

                            else
                                return AssetBook.ActionPanelIcons[nextAction]
                            end
                        end),

                        [Children] = {
                            Components.RoundUICorner(),
                            Components.UIStroke({
                                Enabled = true,
                                Thickness = 2.7,

                                Transparency = Tween(Computed(function(use)
                                    return if use(info.actionIsSelecting) then 0.3 else 1
                                end), AssetBook.TweenInfos.twiceHalf)
                            }),
                            Components.HoverImageButton({
                                [OnEvent("MouseEnter")] = function()
                                    info.actionIsSelecting:set(true)
                                end,
                                [OnEvent("MouseLeave")] = function()
                                    info.actionIsSelecting:set(false)
                                end
                            })
                        }
                    }),

                    Components.HoverImageButton({
                        [OnEvent("MouseEnter")] = function()
                            info.isSelecting:set(true)
                        end,
                        [OnEvent("MouseLeave")] = function()
                            info.isSelecting:set(false)
                        end,
                    }),

                    Fusion.New("Frame")({
                        Name = "HP",
                        BackgroundColor3 = fromRGB(),
                        Position = fromScale(0.12, 0.53),
                        Size = fromScale(0.625, 0.35),

                        [Children] = {
                            Components.RoundUICorner(),
                            New("Frame")({
                                Name = "Bar",

                                BackgroundColor3 = Tween(Computed(function(use)
                                    local HP, maxHP = use(info.HP) :: number, use(info.MaxHP) :: number

                                    if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
                                        return fromRGB(148, 148, 0)
                                    elseif HP / maxHP <= 0.33 then
                                        return fromRGB(203, 0, 0)
                                    else
                                        return fromRGB(0, 120, 104)
                                    end
                                end), AssetBook.TweenInfos.onceHalf),
                                Size = Tween(Computed(function(use)
                                    local x = clamp(use(info.HP) / use(info.MaxHP), 0, 1)

                                    return fromScale(x, 1)
                                end), AssetBook.TweenInfos.halfBack),

                                [Children] = { Components.RoundUICorner() }
                            }),
                            Components.TextLabel({
                                Name = "Stat",
                                Size = fromScale(1, 1),
                                ZIndex = 2,
                                TextStrokeTransparency = 0.7,
                                TextXAlignment = Enum.TextXAlignment.Right,
                                Text = Computed(function(use)
                                    return use(info.HP) .. "/" .. use(info.MaxHP)
                                end),

                                [Children] = {
                                    New("UIPadding")({ PaddingRight = udimNew(0.04, 0) })
                                }
                            }),
                            Components.TextLabel({
                                Name = "Title",
                                Text = "HP",
                                Size = fromScale(1, 1),
                                ZIndex = 2,
                                TextStrokeTransparency = 0.7,
                                TextXAlignment = Enum.TextXAlignment.Left,

                                [Children] = {
                                    New("UIPadding")({ PaddingLeft = udimNew(0.04, 0) })
                                }
                            })
                        }
                    })
                }
            })
        }
    })
end

return TurnBasePlrBar
