--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Tween, Computed, Value, New, OnEvent =
    Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.Value, Fusion.New, Fusion.OnEvent

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fontFromName = Font.fromName
local fromRGB = Color3.fromRGB
local udimNew = UDim.new
local insert, tFind = table.insert, table.find
local clamp = math.clamp

local function MobPhaseMobBar(mob: Model, self: table) : Frame
    local info = {
        innerPos = Value(fromScale(0.82, 0)),
        isSelecting = Value(false),

        Targeting = Value(if self.charData.TargetMonster.Value == mob then true else false),
        HP = Value(mob:GetAttribute("Health")),
        MaxHP = Value(mob:GetAttribute("MaxHealth"))
    }
    Fusion.Hydrate(self.charData.TargetMonster)({
		[Fusion.OnChange("Value")] = function(newTarget: Model?)
			if not newTarget then return end

			info.Targeting:set(mob == newTarget)
		end
	})
	Fusion.Hydrate(mob)({
		[Fusion.AttributeChange("Health")] = function(hp: number)
			info.HP:set(hp)

			if hp <= 0 then info.innerPos:set(fromScale(1.3, 0)) end
		end,
		[Fusion.AttributeChange("MaxHealth")] = function(hp: number)
			info.MaxHP:set(hp)
		end
	})

    return Components.Frame({
        Name = mob.Name,

        [Children] = {
            Components.Frame({
                Name = "Mob",
                AnchorPoint = v2New(),
                BackgroundTransparency = 0,
                Size = fromScale(0.18, 1),

                Position = Tween(Computed(function(use)
                    return use(info.innerPos)
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
                        Name = "MobAvatar",
                        Image = AssetBook.MonsterAvatars[mob.Name],
                        Size = fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,

                        [Children] = { Components.RoundUICorner() }
                    }),
                    Components.TextLabel({
                        Name = "MobName",
                        Position = fromScale(0.253, 0.1),
                        Size = fromScale(0.627, 0.35),
                        Text = mob.Name,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Components.TextLabel({
                        Name = "MobLvl",
                        Position = fromScale(0.253, 0.1),
                        Size = fromScale(0.627, 0.35),
                        Text = "Lv."..mob:GetAttribute("Levels"),
                        TextColor3 = fromRGB(234, 234, 117),
                        TextXAlignment = Enum.TextXAlignment.Right
                    }),
                    Components.TextLabel({
                        Name = "Targeting",
                        AnchorPoint = v2New(0, 0.5),
                        Size = fromScale(0.8, 0.8),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        FontFace = fontFromName("Roboto", Enum.FontWeight.Bold),
                        Text = ">",

                        Visible = Computed(function(use)
                            return use(info.Targeting)
                        end),
                        Position = Tween(Computed(function(use)
                            return use(self.monsterTargetingPos)
                        end), AssetBook.TweenInfos.half),

                        [Children] = { Components.TextUIStroke({ Thickness = 3 }) }
                    }),
                    Components.HoverImageButton({
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
                                Events.ChangeMobTarget:Fire(mob)

                                for _, child: ObjectValue in ipairs(monsterSymbols) do
                                    if child.Value then insert(monsters, child.Value) end
                                end
                                if #monsters > 0 then
                                    local index = tFind(monsters, mob)
                                    if index then self.nowMobIndex = index end
                                end
                            end
						end
                    }),

                    Fusion.New("Frame")({
                        Name = "HP",
                        BackgroundColor3 = fromRGB(),
                        Position = fromScale(0.253, 0.53),
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
            }),
        }
    })
end

return MobPhaseMobBar
