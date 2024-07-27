--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local PanelFilter = require(RepS.Modules.UI.Components.PanelFilter)
local StatsViewBar = require(RepS.Modules.UI.Components.StatsViewBar)
local StatsAddBar = require(RepS.Modules.UI.Components.StatsAddBar)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function CharacterFrame(self: table): Frame
	local scope = self.scope :: Fusion.Scope

	return Components.Frame(scope, {
		Name = "Character",
		Position = fromScale(0.496, 0.531),
		Size = fromScale(0.944, 0.7),

		Visible = Computed(scope, function(use: Fusion.Use)
			return use(self.frames.Character)
		end),

		[Children] = {
			New(scope, "UIAspectRatioConstraint")({ AspectRatio = 3.389 }),

			Fusion.New(scope, "Frame")({
				Name = "LeftPanel",
				BackgroundTransparency = 1,
				Size = fromScale(0.3, 1),

				[Children] = {
					Fusion.New(scope, "UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = udNew(0.04, 0)
					}),

					PanelFilter("Attributes", "Character", self),
					PanelFilter("Points", "Character", self),
					PanelFilter("Classes", "Character", self),
					PanelFilter("Talents", "Character", self)
				}
			}),
			Fusion.New(scope, "Frame")({
				Name = "RightPanel",
				BackgroundTransparency = 1,
				Position = fromScale(0.7, 0),
				Size = fromScale(0.3, 1),

				[Children] = {
					Components.Frame(scope, {
						Name = "Attributes",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Character.Attributes)
						end),

						[Children] = {
							Fusion.New(scope, "UIListLayout")({
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = udNew(0.04, 0)
							}),

							StatsViewBar("Levels", self, "LEVEL", 1),

							Components.Frame(scope, {
								Name = "EXPBar",
								Size = fromScale(1, 0.02),
								LayoutOrder = 2,

								[Children] = {
									Components.RoundUICorner(scope),

									Fusion.New(scope, "Frame")({
										Name = "Bar",
										BackgroundColor3 = fromRGB(217, 193, 144),

										Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
											local x = math.clamp(use(self.playerData.EXP[1]) / use(self.playerData.EXP[2]), 0, 1)

											return fromScale(x, 1)
										end), AssetBook.TweenInfos.halfBack),

										[Children] = { Components.RoundUICorner(scope) }
									})
								}
							}),

							StatsViewBar("Health", self, "HEALTH", 3),
							StatsViewBar("DMG", self, "DMG", 4),
							StatsViewBar("Magic", self, "MAGIC", 5),
							StatsViewBar("Mana", self, "MANA", 6),
							StatsViewBar("Shield", self, "SHIELD", 7),
							StatsViewBar("CriChance", self, "CRIT CHANCE", 8),
							StatsViewBar("CriDMG", self, "CRIT DMG", 9)
						}
					}),
					Components.Frame(scope, {
						Name = "Points",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Character.Points)
						end),

						[Children] = {
							Fusion.New(scope, "UIListLayout")({
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = udNew(0.053, 0)
							}),

							StatsViewBar("PSV", self, "PSV", 1),
							StatsViewBar("SkillPoints", self, "SKILL POINTS", 2),

							StatsAddBar("Health", self, "HEALTH", 3),
							StatsAddBar("DMG", self, "DMG", 4),
							StatsAddBar("Magic", self, "MAGIC", 5),
							StatsAddBar("Mana", self, "MANA", 6),
							StatsAddBar("Shield", self, "SHIELD", 7),
							StatsAddBar("ResetCost", self, "RESET COST (RP)", 8)
						}
					}),
					Components.Frame(scope, {
						Name = "Classes",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Character.Classes)
						end),

						[Children] = {
							Fusion.New(scope, "Frame")({
								Name = "ClassList",
								BackgroundTransparency = 1,
								Size = fromScale(1, 0.15),

								[Children] = {
									Fusion.New(scope, "UIGridLayout")({
										CellPadding = fromScale(0.04, 0.1),
										CellSize = fromScale(0.135, 0.9),
										SortOrder = Enum.SortOrder.LayoutOrder
									}),

									Fusion.ForPairs(scope, AssetBook.ClassInfo, function(_, localScope: Fusion.Scope, class: string, info: table)
										local isSelecting = Fusion.Value(localScope, false)
										local clickCD = false

										return class, Components.Frame(localScope, {
											Name = class,
											BackgroundColor3 = fromRGB(),
											BackgroundTransparency = 0,
											LayoutOrder = info.Order,

											[Children] = {
												Components.RoundUICorner(scope),
												Components.UIStroke(scope, {
													Thickness = 3,
													Enabled = true,

													Transparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
														if use(self.playerData.Class) == class then
															return 0.3
														else
															return if use(isSelecting) then 0.3 else 1
														end
													end), AssetBook.TweenInfos.twiceHalf),
												}),
												Components.HoverImageButton(scope, {
													Image = Computed(localScope, function(use: Fusion.Use)
														if use(self.playerData.ClassUnlocks[class]) then
															return info.Image
														else
															return ItemBook.ItemImagesEx.ClassLock
														end
													end),

													[Fusion.OnEvent("MouseEnter")] = function()
														isSelecting:set(true)
													end,
													[Fusion.OnEvent("MouseLeave")] = function()
														isSelecting:set(false)
													end,
													[Fusion.OnEvent("MouseButton1Click")] = function()
														if clickCD then return end

														clickCD = true
														Spawn(function()
															task.wait(0.15)
															clickCD = false
														end)

														if self.plr:GetAttribute("CLASS_UNLOCK_"..class) then
															self.classInfoDesc:set(info.Desc)
															Events.ChangePlayerClass.Fire({ ClassId = class })
														else
															self.classInfoDesc:set("LOCKED")
														end
													end
												})
											}
										})
									end)
								}
							}),
							Components.TextLabel(scope, {
								Name = "ClassDesc",
								Position = fromScale(0, 0.5),
								Size = fromScale(1, 0.5),
								TextScaled = false,
								FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Bottom,
								TextTransparency = 0.5,
								TextWrapped = true,

								[Fusion.Out("AbsoluteSize")] = self.classInfoAbsSize,

								TextSize = Computed(scope, function(use: Fusion.Use)
									return math.clamp(use(self.classInfoAbsSize).Y / 7.5, 1, 35)
								end),
								Text = Computed(scope, function(use: Fusion.Use)
									return use(self.classInfoDesc)
								end)
							})
						}
					}),
					Components.Frame(scope, {
						Name = "Talents",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.panelFilterFrames.Character.Talents)
						end)
					})
				}
			})
		},
	})
end

return CharacterFrame
