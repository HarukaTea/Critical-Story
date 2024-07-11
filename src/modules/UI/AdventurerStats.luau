--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local EXPFormula = require(RepS.Modules.Data.EXPFormula)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerStatsPinia)

local ClassFrame = require(RepS.Modules.UI.Views.ClassFrame)
local ItemAcquiredFrame = require(RepS.Modules.UI.Views.ItemAcquiredFrame)
local LevelUpVFXFrame = require(RepS.Modules.UI.Views.LevelUpVFXFrame)
local LocationTitleFrame = require(RepS.Modules.UI.Views.LocationTitleFrame)
local MonsterSideList = require(RepS.Modules.UI.Views.MonsterSideList)
local PromptsFrame = require(RepS.Modules.UI.Views.PromptsFrame)
local PlayerEffectsList = require(RepS.Modules.UI.Views.PlayerEffectsList)
local QuestFrame = require(RepS.Modules.UI.Views.QuestFrame)
local StatsTextsFrame = require(RepS.Modules.UI.Views.StatsTextsFrame)

local AlchemistAbilityIndicator = require(RepS.Modules.UI.Components.AlchemistAbilityIndicator)
local ClassAbilityIndicator = require(RepS.Modules.UI.Components.ClassAbilityIndicator)
local EXPProgressBar = require(RepS.Modules.UI.Components.EXPProgressBar)
local StatBar = require(RepS.Modules.UI.Components.StatBar)

local Children, New = Fusion.Children, Fusion.New

local AdventurerStats = {}
AdventurerStats.__index = AdventurerStats
AdventurerStats.__type = "AdventuerStats"

local wait = task.wait
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local match = string.match

return function(plr: Player)
	local self = setmetatable({}, AdventurerStats)

	self.plr = plr
	self.plrGui = plr:FindFirstChildOfClass("PlayerGui")
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local scope = self.scope :: Fusion.Scope
	local UI = Components.ScreenGui(scope, {
		Name = "AdventurerStats",
		DisplayOrder = 2,
		Parent = self.plrGui,

		[Children] = {
			Components.Frame(scope, {
				Name = "BottomBG",
				AnchorPoint = v2New(0.5, 0.9),
				Position = fromScale(0.5, 1),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				Visible = Fusion.Computed(scope, function(use)
					return not use(self.isChatting)
				end),

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 24.915 }),

					EXPProgressBar(self),

					Components.Frame(scope, {
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.42),

						[Children] = {
							New(scope, "UIListLayout")({
								Padding = udNew(0.01, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
							}),

							StatBar("DEF", self),
							StatBar("HP", self),
							StatBar("MP", self),
						},
					}),
					Components.TextLabel(scope, {
						Name = "Location",
						Position = fromScale(0, 0.4),
						Size = fromScale(1, 0.3),
						FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
						TextTransparency = 0.5,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = RepS.Package.ServerLocation.Value.." / "
							..(if RepS.Package.PrivateServerId.Value == "" then "?" else RepS.Package.PrivateServerId.Value).." / v"
							..RepS.Package.Version.Value,

						[Children] = {
							New(scope, "UIPadding")({ PaddingLeft = udNew(0.01, 0) }),
							New(scope, "UITextSizeConstraint")({ MaxTextSize = 14 })
						}
					}),
					Components.TextLabel(scope, {
						Name = "UID",
						Position = fromScale(0, 0.4),
						Size = fromScale(1, 0.3),
						FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
						TextTransparency = 0.5,
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = "UID: "..plr.UserId,

						[Children] = {
							New(scope, "UIPadding")({ PaddingRight = udNew(0.01, 0) }),
							New(scope, "UITextSizeConstraint")({ MaxTextSize = 14 })
						}
					}),

					ClassFrame(self),
					StatsTextsFrame(self),
					MonsterSideList(self),
					PlayerEffectsList(self)
				},
			}),
			Components.Frame(scope, {
				Name = "TopBG",
				AnchorPoint = v2New(0.5, 0),
				Position = ud2New(0.5, 0, 0, 58),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 24.915 }),

					LocationTitleFrame(self),
					LevelUpVFXFrame(self),
				}
			}),
			Components.Frame(scope, {
				Name = "CenterBG",
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 24.915 }),

					PromptsFrame(self),
					ItemAcquiredFrame(self),
					QuestFrame(self),

					ClassAbilityIndicator(self, "Warrior"),
					ClassAbilityIndicator(self, "Archer"),
					ClassAbilityIndicator(self, "Wizard"),
					ClassAbilityIndicator(self, "Knight"),
					ClassAbilityIndicator(self, "Rogue"),

					AlchemistAbilityIndicator(self),

					ClassAbilityIndicator(self, "Juggernaut"),
					ClassAbilityIndicator(self, "Reaper")
				}
			})
		},
	})

	self.nowMobIndex = 1
	local function _changeMobTarget(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		local monsters = self.char.CharStats.TargetMonsters:GetChildren()
		if #monsters > 0 then
			workspace.Sounds.SFXs.SelectionConfirmed:Play()

			self.nowMobIndex += 1
			if self.nowMobIndex > #monsters then self.nowMobIndex = 1 end

			Events.ChangeMobTarget:Fire(monsters[self.nowMobIndex].Value)
		end
	end
	local function _useItem(actionName: string, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		self:UseItem(tonumber(match(actionName, "%d")))
	end
	CAS:BindAction("ChangeMobTargetLCtrl", _changeMobTarget, false, Enum.KeyCode.LeftControl)
	CAS:BindAction("ChangeMobTargetRCtrl", _changeMobTarget, false, Enum.KeyCode.RightControl)
	CAS:BindAction("UseItem1", _useItem, false, Enum.KeyCode.One)
	CAS:BindAction("UseItem2", _useItem, false, Enum.KeyCode.Two)
	CAS:BindAction("UseItem3", _useItem, false, Enum.KeyCode.Three)

	--- Setups
	local function _autoEquipItems()
		for _, item in self.inventory:GetChildren() do
			if item.Value > 0 and item:GetAttribute("Equipped") then
				Events.EquipItems:Fire(ItemBook:FindItem(item.Name).Type, item:GetAttribute("Slot"), item.Name)
			end
		end
	end
	Spawn(_autoEquipItems)
	local function _moveUpJumpBtn()
		local isMobile = HarukaLib:GetDevice() == "Mobile"

		if isMobile then
			local touchGui = plr:FindFirstChildOfClass("PlayerGui"):WaitForChild("TouchGui", 999) :: ScreenGui

			touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999).AnchorPoint = v2New(0.82, 0.8)
			touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999).Position = fromScale(0.82, 0.8)
		end
	end
	Spawn(_moveUpJumpBtn)

	---// Listening events
	local playerData = self.playerData
	table.insert(scope, HarukaLib:Hydrate(plr, {
		["Attr-EXP"] = function(exp: number)
			playerData.EXP[1]:set(exp)
			playerData.EXP[2]:set(EXPFormula(plr:GetAttribute("Levels")))
		end,
		["Attr-Levels"] = function(level: number)
			playerData.Levels:set(level)
			playerData.EXP[2]:set(EXPFormula(level))
		end,
		["Attr-Class"] = function(class: string)
			playerData.Class:set(class)
		end,
		["Attr-Gold"] = function(gold: number)
			playerData.Gold:set(HarukaLib:NumberConvert(gold, "%.1f"))
		end,
		["Attr-RP"] = function(rp: number)
			playerData.RP:set(HarukaLib:NumberConvert(rp, "%.1f"))
		end,
		["Attr-LvPoints"] = function(lvPoints: number)
			playerData.LvPoints:set(lvPoints)
		end,

		["Attr-InChatting"] = function(newState: boolean)
			self.isChatting:set(newState)
		end
	}))

	local charClassInfo = self.charClassInfo
	table.insert(scope, HarukaLib:Hydrate(self.char, {
		["Attr-Combo"] = function(combo: number)
			charClassInfo.Warrior:set(combo)

            if combo <= 0 then return end

			local bar = UI.CenterBG.WarriorStyle.BarBG.TweenBar :: Frame
			TS:Create(bar, AssetBook.TweenInfos.twiceHalf, { Size = fromScale(1, 1) }):Play()
            wait(0.2)
            TS:Create(bar, AssetBook.TweenInfos.twiceHalfOne, { Size = fromScale(0, 1) }):Play()
		end,
		["Attr-Stack"] = function(arrows: number)
			charClassInfo.Archer:set(arrows)
		end,
		["Attr-Focus"] = function(casted: number)
			charClassInfo.Wizard:set(casted)
		end,
		["Attr-Guard"] = function(guarded: number)
			charClassInfo.Knight:set(guarded)
		end,
		["Attr-RogueCri"] = function(rogueCri: number)
			charClassInfo.Rogue:set(rogueCri)
		end,
		["Attr-Rage"] = function(rage: number)
			charClassInfo.Juggernaut:set(rage)
		end,
		["Attr-LifeStolen"] = function(lifeStolen: number)
			charClassInfo.Reaper:set(lifeStolen)
		end,

		["Attr-InCombat"] = function(newState: boolean)
			self.charStatsDict.IsInCombat:set(newState)
		end
	}))

	local charStatsDict = self.charStatsDict
	table.insert(scope, HarukaLib:Hydrate(self.char, {
		["Attr-Mana"] = function(mana: number)
			charStatsDict.MP[1]:set(mana)
		end,
		["Attr-MaxMana"] = function(maxMana: number)
			charStatsDict.MP[2]:set(maxMana)
		end,
		["Attr-Shield"] = function(shield: number)
			charStatsDict.DEF[1]:set(shield)
		end,
		["Attr-MaxShield"] = function(maxShield: number)
			charStatsDict.DEF[2]:set(maxShield)
		end,
		["Attr-HPRecovering"] = function(state: boolean)
			charStatsDict.HPHealing:set(state)
		end,
		["Attr-ShieldRepairing"] = function(state: boolean)
			charStatsDict.DEFRepairing:set(state)
		end
	}))
	table.insert(scope, HarukaLib:Hydrate(self.humanoid, {
		["Prop-Health"] = function(health: number)
			charStatsDict.HP[1]:set(health)
		end,
		["Prop-MaxHealth"] = function(health: number)
			charStatsDict.HP[2]:set(health)
		end
	}))

	local function _clearGarbage()
		CAS:UnbindAction("ChangeMobTargetLCtrl")
		CAS:UnbindAction("ChangeMobTargetRCtrl")
		CAS:UnbindAction("UseItem1")
		CAS:UnbindAction("UseItem2")
		CAS:UnbindAction("UseItem3")

		Events.EquipItems:DisconnectAll()
		Events.GiveDrop:DisconnectAll()
		Events.LevelUp:DisconnectAll()

		Signals.ExCategoryOpened:DisconnectAll()

		Fusion.doCleanup(scope)

		self = nil
	end
	self.humanoid.Died:Once(_clearGarbage)
end
