--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local TurnBaseEffectList = require(RepS.Modules.UI.Views.TurnBaseEffectList)

local Children, Tween, Computed, Value, New, OnEvent =
    Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.Value, Fusion.New, Fusion.OnEvent

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fontFromName = Font.fromName
local fromRGB = Color3.fromRGB
local udimNew = UDim.new
local insert, tFind = table.insert, table.find
local clamp = math.clamp
local wait = task.wait

local function TurnBaseMonsterBar(monster: Model, self: table, scope: table) : Frame
    local info = {
        innerPos = Value(scope, fromScale(0.82, 0)),
        isSelecting = Value(scope, false),

        Targeting = Value(scope, if self.charData.TargetMonster.Value == monster then true else false),
        HP = Value(scope, monster:GetAttribute("Health")),
        MaxHP = Value(scope, monster:GetAttribute("MaxHealth")),

        EffectsList = Value(scope, {})
    }
    scope[#scope + 1] = HarukaLib:Hydrate(self.charData.TargetMonster, {
        ["Prop-Value"] = function(newTarget: Model?)
            if not newTarget then return end

			info.Targeting:set(monster == newTarget)
        end
    })
    scope[#scope + 1] = HarukaLib:Hydrate(monster, {
        ["Attr-Health"] = function(hp: number)
            info.HP:set(hp)

			if hp <= 0 then info.innerPos:set(fromScale(1.3, 0)) end
        end,
        ["Attr-MaxHealth"] = function(hp: number)
            info.MaxHP:set(hp)
        end
    })

    local function _setEffectsChildren()
		wait()
		info.EffectsList:set(monster.EffectsList:GetChildren())
	end
    scope[#scope + 1] = HarukaLib:Hydrate(monster.EffectsList, {
        ["ChildAdded"] = _setEffectsChildren,
        ["ChildRemoved"] = _setEffectsChildren
    })

    return Components.Frame(scope, {
        Name = monster.Name,

        [Children] = {
            Components.Frame(scope, {
                Name = "Monster",
                AnchorPoint = v2New(),
                BackgroundTransparency = 0,
                Size = fromScale(0.18, 1),

                Position = Tween(scope, Computed(scope, function(use)
                    return use(info.innerPos)
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
                    Components.ImageLabel(scope, {
                        Name = "MobAvatar",
                        Image = AssetBook.MonsterInfo[monster.Name].Icon,
                        Size = fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,

                        [Children] = { Components.RoundUICorner(scope) }
                    }),
                    Components.TextLabel(scope, {
                        Name = "MobName",
                        Position = fromScale(0.253, 0.1),
                        Size = fromScale(0.627, 0.35),
                        Text = AssetBook.MonsterInfo[monster.Name].Name,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Components.TextLabel(scope, {
                        Name = "MobLvl",
                        Position = fromScale(0.253, 0.1),
                        Size = fromScale(0.627, 0.35),
                        Text = "Lv."..monster:GetAttribute("Levels"),
                        TextColor3 = fromRGB(234, 234, 117),
                        TextXAlignment = Enum.TextXAlignment.Right
                    }),
                    Components.TextLabel(scope, {
                        Name = "Targeting",
                        AnchorPoint = v2New(0, 0.5),
                        Size = fromScale(0.8, 0.8),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        FontFace = fontFromName("Roboto", Enum.FontWeight.Bold),
                        Text = ">",

                        Visible = Computed(scope, function(use)
                            return use(info.Targeting)
                        end),
                        Position = Tween(scope, Computed(scope, function(use)
                            return use(self.monsterTargetingPos)
                        end), AssetBook.TweenInfos.half),

                        [Children] = { Components.TextUIStroke(scope, { Thickness = 3 }) }
                    }),
                    Components.HoverImageButton(scope, {
                        [OnEvent("MouseEnter")] = function()
                            info.isSelecting:set(true)
                        end,
                        [OnEvent("MouseLeave")] = function()
                            info.isSelecting:set(false)
                        end,
                        [OnEvent("MouseButton1Click")] = function()
							workspace.Sounds.SFXs.SelectionConfirmed:Play()

                            local monsterSymbols = self.charData.TargetMonsters:GetChildren() :: table
							local monsters = {}
                            if #monsterSymbols > 1 then
                                Events.ChangeMobTarget:Fire(monster)

                                for _, child: ObjectValue in ipairs(monsterSymbols) do
                                    if child.Value then insert(monsters, child.Value) end
                                end
                                if #monsters > 0 then
                                    local index = tFind(monsters, monster)
                                    if index then self.nowMobIndex = index end
                                end
                            end
						end
                    }),

                    Fusion.New(scope, "Frame")({
                        Name = "HP",
                        BackgroundColor3 = fromRGB(),
                        Position = fromScale(0.253, 0.53),
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

                    TurnBaseEffectList("Monster", info, self)
                }
            }),
        }
    })
end

return TurnBaseMonsterBar
