--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local TurnBaseEffectList = require(RepS.Modules.UI.Views.TurnBaseEffectList)

local Children, Tween, Computed, New, OnEvent, Value =
    Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.New, Fusion.OnEvent, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udimNew = UDim.new
local clamp = math.clamp
local wait = task.wait
local fontFromName = Font.fromName

local function TurnBasePlrBar(char: Model, self: table, scope: table) : Frame
    local plr = Players:GetPlayerFromCharacter(char)
    local info = {
        isSelecting = Value(scope, false),

        HP = Value(scope, char.Humanoid.Health),
        MaxHP = Value(scope, char.Humanoid.MaxHealth),
        NextAction = Value(scope, ""),

        EffectsList = Value(scope, {})
    }

    HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            info.HP:set(newHP)
        end,
        ["Prop-MaxHealth"] = function(newHP: number)
            info.MaxHP:set(newHP)
        end
    })
    HarukaLib:Hydrate(plr, {
        ["Attr-NextAction"] = function(newAction: string)
            info.NextAction:set(newAction)
        end
    })

    local function _setEffectsChildren()
		wait()
		info.EffectsList:set(char.CharStats.EffectsList:GetChildren())
	end
    HarukaLib:Hydrate(char.CharStats.EffectsList, {
        ["ChildAdded"] = _setEffectsChildren,
        ["ChildRemoved"] = _setEffectsChildren
    })

    return Components.Frame(scope, {
        Name = char.Name,

        [Children] = {
            Components.Frame(scope, {
                Name = "Player",
                AnchorPoint = v2New(),
                BackgroundTransparency = 0,
                Size = fromScale(0.18, 1),

                Position = Tween(scope, Computed(scope, function(use)
                    if use(self.targetingMob) and use(self.targetingMob):FindFirstChild("TargetPlayers") then
                        if use(self.targetingMob).TargetPlayers:FindFirstChild(char.Name) then
                            return fromScale(0, 0)
                        else
                            return fromScale(-0.3, 0)
                        end
                    end
                end), AssetBook.TweenInfos.twiceHalfOne),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Thickness = 2.7,
                        Enabled = true,

                        Transparency = Tween(scope, Computed(scope, function(use)
                            return if use(info.isSelecting) then 0.3 else 1
                        end), AssetBook.TweenInfos.twiceHalf)
                    }),
                    Components.TextLabel(scope, {
                        Name = "PlayerName",
                        Position = fromScale(0.117, 0.1),
                        Size = fromScale(0.634, 0.35),
                        Text = plr.DisplayName,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextColor3 = AssetBook.ClassInfo[plr:GetAttribute("Class")].Color,
                    }),
                    Components.TextLabel(scope, {
                        Name = "Targeting",
                        AnchorPoint = v2New(0, 0.5),
                        Size = fromScale(0.8, 0.8),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        FontFace = fontFromName("Roboto", Enum.FontWeight.Bold),
                        Text = "<",

                        Visible = Computed(scope, function(use)
                            return if use(self.targetingPlayer) == plr then true else false
                        end),
                        Position = Tween(scope, Computed(scope, function(use)
                            return use(self.playerTargetingPos)
                        end), AssetBook.TweenInfos.half),

                        [Children] = { Components.TextUIStroke(scope, { Thickness = 3 }) }
                    }),
                    Components.ImageLabel(scope, {
                        Name = "NextAction",
                        Position = fromScale(0.78, 0),
                        Size = fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,

                        Image = Computed(scope, function(use)
                            local nextAction = use(info.NextAction)

                            if nextAction == "" or nextAction == nil then
                                return ItemBook.ItemImagesEx.Null

                            elseif nextAction == "Attack" then
                                return AssetBook.ClassInfo[plr:GetAttribute("Class")].Image

                            elseif nextAction == "Items" then
                                return "rbxassetid://"..ItemBook:FindItem(plr:GetAttribute("NextItem")).Icon

                            else
                                return AssetBook.ActionPanelIcons[nextAction]
                            end
                        end),

                        [Children] = { Components.RoundUICorner(scope) }
                    }),

                    Components.HoverImageButton(scope, {
                        [OnEvent("MouseEnter")] = function()
                            info.isSelecting:set(true)
                        end,
                        [OnEvent("MouseLeave")] = function()
                            info.isSelecting:set(false)
                        end,
                        [OnEvent("MouseButton1Click")] = function()
                            self.targetingPlayer:set(plr)

                            workspace.Sounds.SFXs.SelectionConfirmed:Play()
                        end
                    }),

                    Fusion.New(scope, "Frame")({
                        Name = "HP",
                        BackgroundColor3 = fromRGB(),
                        Position = fromScale(0.12, 0.53),
                        Size = fromScale(0.625, 0.35),

                        [Children] = {
                            Components.RoundUICorner(scope),
                            New(scope, "Frame")({
                                Name = "Bar",

                                BackgroundColor3 = Tween(scope, Computed(scope, function(use)
                                    local HP, maxHP = use(info.HP) :: number, use(info.MaxHP) :: number

                                    if HP / maxHP <= 0.66 and HP / maxHP > 0.33 then
                                        return fromRGB(148, 148, 0)
                                    elseif HP / maxHP <= 0.33 then
                                        return fromRGB(203, 0, 0)
                                    else
                                        return fromRGB(0, 120, 104)
                                    end
                                end), AssetBook.TweenInfos.onceHalf),
                                Size = Tween(scope, Computed(scope, function(use)
                                    local x = clamp(use(info.HP) / use(info.MaxHP), 0, 1)

                                    return fromScale(x, 1)
                                end), AssetBook.TweenInfos.halfBack),

                                [Children] = { Components.RoundUICorner(scope) }
                            }),
                            Components.TextLabel(scope, {
                                Name = "Stat",
                                Size = fromScale(1, 1),
                                ZIndex = 2,
                                TextStrokeTransparency = 0.7,
                                TextXAlignment = Enum.TextXAlignment.Right,

                                Text = Computed(scope, function(use)
                                    return use(info.HP) .. "/" .. use(info.MaxHP)
                                end),

                                [Children] = {
                                    New(scope, "UIPadding")({ PaddingRight = udimNew(0.04, 0) })
                                }
                            }),
                            Components.TextLabel(scope, {
                                Name = "Title",
                                Text = "HP",
                                Size = fromScale(1, 1),
                                ZIndex = 2,
                                TextStrokeTransparency = 0.7,
                                TextXAlignment = Enum.TextXAlignment.Left,

                                [Children] = {
                                    New(scope, "UIPadding")({ PaddingLeft = udimNew(0.04, 0) })
                                }
                            })
                        }
                    }),

                    TurnBaseEffectList("Player", info, self)
                }
            })
        }
    })
end

return TurnBasePlrBar
