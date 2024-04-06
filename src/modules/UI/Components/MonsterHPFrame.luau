--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed, Tween, Hydrate, Value, OnEvent =
	Fusion.Children, Fusion.Computed, Fusion.Tween, Fusion.Hydrate, Fusion.Value, Fusion.OnEvent

local MonsterEffect = require(RepS.Modules.UI.Components.MonsterEffect)

local wait = task.wait
local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local clamp = math.clamp
local udNew = UDim.new
local tFind, insert = table.find, table.insert

local function MonsterHPFrame(info: table, self: table): Frame
	local innerPosition = Value(fromScale(1.02, 0))
	local stroke_trans = Value(1)

	Hydrate(self.charData.TargetMonster)({
		[Fusion.OnChange("Value")] = function(newTarget: Model?)
			if not newTarget then return end

			info.Targeting:set(info.Model == newTarget)
		end
	})
	Hydrate(info.Model)({
		[Fusion.AttributeChange("Health")] = function(hp: number)
			info.HP:set(hp)

			if hp <= 0 then innerPosition:set(fromScale(1.5, 0)) end
		end,
		[Fusion.AttributeChange("MaxHealth")] = function(hp: number)
			info.MaxHP:set(hp)
		end
	})

	local function _setNewEffectList()
		wait()
		if not info.Model then return end
		if not info.Model:FindFirstChild("EffectsList") then return end

		info.EffectsList:set(info.Model.EffectsList:GetChildren())
	end
	Hydrate(info.Model.EffectsList)({
		[Fusion.OnEvent("ChildAdded")] = _setNewEffectList,
		[Fusion.OnEvent("ChildRemoved")] = _setNewEffectList
	})

	return Components.Frame({
		Name = "MonsterHPFrame",
		AnchorPoint = v2New(0.5, 0),
		Position = fromScale(0.5, -2.7),

		[Children] = {
			Components.Frame({
				BackgroundTransparency = 0.3,
				AnchorPoint = v2New(1, 0),
				Size = fromScale(0.3, 1),
				Position = Tween(Computed(function(use)
					return use(innerPosition)
				end), AssetBook.TweenInfos.twiceHalfOne),

				[Children] = {
					Components.RoundUICorner(),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,
						Transparency = Tween(Computed(function(use)
							return use(stroke_trans)
						end), AssetBook.TweenInfos.twiceHalf)
					}),
					Components.ImageLabel({
						Name = "Avatar",
						BackgroundTransparency = 0,
						Size = fromScale(0.142, 1),
						Image = info.Avatar,

						[Children] = { Components.RoundUICorner() },
					}),
					Components.TextLabel({
						Name = "MonsterName",
						Position = fromScale(0.163, 0.05),
						Size = fromScale(0.726, 0.4),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextStrokeTransparency = 0,
						Text = info.Name,
					}),
					Components.TextLabel({
						Name = "MonsterLevel",
						Position = fromScale(0.163, 0.05),
						Size = fromScale(0.726, 0.4),
						TextColor3 = fromRGB(255, 255, 0),
						TextStrokeTransparency = 0,
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = "Lv." .. info.Level,
					}),
					Components.Frame({
						Name = "HP",
						AnchorPoint = v2New(),
						BackgroundTransparency = 0,
						Position = fromScale(0.16, 0.53),
						Size = fromScale(0.748, 0.33),

						[Children] = {
							Components.RoundUICorner(),
							Fusion.New("Frame")({
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

								[Children] = { Components.RoundUICorner() },
							}),
							Components.TextLabel({
								Name = "Title",
								AnchorPoint = v2New(0.5, 0),
								Position = fromScale(0.5, 0),
								Size = fromScale(0.95, 1),
								TextStrokeTransparency = 0.7,
								Text = "HEALTH",
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
							Components.TextLabel({
								Name = "Stats",
								AnchorPoint = v2New(0.5, 0),
								Position = fromScale(0.5, 0),
								Size = fromScale(0.95, 1),
								TextStrokeTransparency = 0.7,
								Text = Computed(function(use)
									return use(info.HP) .. "/" .. use(info.MaxHP)
								end),
								TextXAlignment = Enum.TextXAlignment.Right,
							}),
						},
					}),
					Components.TextLabel({
						Name = "TargetingSign",
						Position = Tween(Computed(function(use)
							return use(self.monsterTargetingPos)
						end), AssetBook.TweenInfos.halfBack),
						Size = fromScale(0.142, 1),
						FontFace = Font.fromName("Roboto", Enum.FontWeight.Bold),
						Text = ">",
						Visible = Computed(function(use)
							return use(info.Targeting)
						end),

						[Children] = { Components.TextUIStroke({ Thickness = 3.5 }) },
					}),
					Components.HoverImageButton({
						Name = "Hover",

						[OnEvent("MouseEnter")] = function()
							stroke_trans:set(0)
						end,
						[OnEvent("MouseLeave")] = function()
							stroke_trans:set(1)
						end,
						[OnEvent("MouseButton1Click")] = function()
							workspace.Sounds.SFXs.SelectionConfirmed:Play()

							Events.ChangeMobTarget:Fire(info.Model)

							local monsterSymbols = self.char.CharStats.TargetMonsters:GetChildren()
							local monsters = {}
							for _, child in ipairs(monsterSymbols) do
								if child.Value then insert(monsters, child.Value) end
							end
							if #monsters > 0 then
								local index = tFind(monsters, info.Model)
								if index then self.nowMobIndex = index end
							end
						end
					}),
					Components.Frame({
						AnchorPoint = v2New(),
						Name = "Effects",
						Position = fromScale(0.491, 0.05),
						Size = fromScale(0.252, 0.4),

						[Children] = {
							Fusion.New("UIListLayout")({
								Padding = udNew(0.03, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right
							}),
							Fusion.ForValues(info.EffectsList, function(use, effect: Script)
								local effectInfo = {
									Script = effect,
									Duration = Value(effect:GetAttribute("Duration")),
								}

								return MonsterEffect(effect.Name, effectInfo, self)
							end, Fusion.cleanup)
						}
					})
				},
			}),
		},
	})
end

return MonsterHPFrame
