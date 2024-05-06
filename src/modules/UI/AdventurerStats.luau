--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local DeviceGetter = require(RepS.Modules.Packages.DeviceGetter)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerStatsPinia)

local ClassFrame = require(RepS.Modules.UI.Views.ClassFrame)
local ChatFrame = require(RepS.Modules.UI.Views.ChatFrame)
local ItemAcquiredFrame = require(RepS.Modules.UI.Views.ItemAcquiredFrame)
local LevelUpVFXFrame = require(RepS.Modules.UI.Views.LevelUpVFXFrame)
local LocationTitleFrame = require(RepS.Modules.UI.Views.LocationTitleFrame)
local PromptsFrame = require(RepS.Modules.UI.Views.PromptsFrame)
local PlayerEffectsList = require(RepS.Modules.UI.Views.PlayerEffectsList)
local QuestFrame = require(RepS.Modules.UI.Views.QuestFrame)
local StatsTextsFrame = require(RepS.Modules.UI.Views.StatsTextsFrame)

local BottomProgressBar = require(RepS.Modules.UI.Components.BottomProgressBar)
local ClassAbilityIndicator = require(RepS.Modules.UI.Components.ClassAbilityIndicator)
local StatBar = require(RepS.Modules.UI.Components.StatBar)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local AdventurerStats = {}
AdventurerStats.__index = AdventurerStats
AdventurerStats.__type = "AdventuerStats"

local wait = task.wait
local floor = math.floor
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale

return function(plr: Player)
	repeat wait() until plr.PlayerGui:WaitForChild("Backpack", 999)

	local self = setmetatable({}, AdventurerStats)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local UI = Components.ScreenGui({
		Name = "AdventurerStats",
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 2,
		Parent = self.plrGui,
		[Fusion.Ref] = self.UI,

		[Children] = {
			Components.Frame({
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				Visible = Computed(function(use)
					return not use(self.charStatsDict.IsInCombat)
				end),
				Position = Fusion.Tween(Computed(function(use)
					return if use(self.charStatsDict.IsInCombat) then fromScale(0.5, 3) else fromScale(0.5, 1)
				end), AssetBook.TweenInfos.twiceHalfOne),

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					BottomProgressBar("EXP", self),

					Components.Frame({
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.42),

						[Children] = {
							New("UIListLayout")({
								Padding = udNew(0.01, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							StatBar("HP", self),
						},
					}),
					Components.TextLabel({
						Name = "Location",
						Position = fromScale(0, 0.4),
						Size = fromScale(1, 0.3),
						FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
						TextTransparency = 0.5,
						TextXAlignment = Enum.TextXAlignment.Left,

						Text = Computed(function(use)
							return use(self.serverLocation).." "..use(self.privateId).." v"..use(self.version)
						end),

						[Children] = {
							New("UIPadding")({ PaddingLeft = udNew(0.01, 0) }),
							New("UITextSizeConstraint")({ MaxTextSize = 14 })
						}
					}),

					ClassFrame(self),
					ChatFrame(self),
					StatsTextsFrame(self),
					PlayerEffectsList(self)
				},
			}),
			Components.Frame({
				Name = "TopBG",
				AnchorPoint = v2New(0.5, 0),
				Position = ud2New(0.5, 0, 0, 58),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					LocationTitleFrame(self),
					LevelUpVFXFrame(self),
				}
			}),
			Components.Frame({
				Name = "CenterBG",
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					PromptsFrame(self),
					ItemAcquiredFrame(self),
					QuestFrame(self),

					ClassAbilityIndicator(self, "Warrior"),
					ClassAbilityIndicator(self, "Archer"),
					ClassAbilityIndicator(self, "Wizard"),
					ClassAbilityIndicator(self, "Knight"),
					ClassAbilityIndicator(self, "Rogue"),
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
	CAS:BindAction("ChangeMobTargetLAlt", _changeMobTarget, false, Enum.KeyCode.LeftAlt)
	CAS:BindAction("ChangeMobTargetRAlt", _changeMobTarget, false, Enum.KeyCode.RightAlt)

	--- Setups
	local function _autoEquipItems()
		for _, item in self.inventory:GetChildren() do
			if item.Value > 0 and item:GetAttribute("Equipped") then
				Events.EquipItems:Fire(ItemBook:FindItem(item.Name).Type, item:GetAttribute("Slot"), item.Name)
			end
		end
	end
	Spawn(_autoEquipItems)
	local function moveUpJumpBtn()
		local isMobile = DeviceGetter:IsPhone() or DeviceGetter:IsTablet()

		if isMobile then
			local touchGui = plr.PlayerGui:WaitForChild("TouchGui", 999) :: ScreenGui

			touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999).AnchorPoint = v2New(0.82, 0.8)
			touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999).Position = fromScale(0.82, 0.8)
		end
	end
	Spawn(moveUpJumpBtn)
	local function charCurrentZone()
		local region = HarukaLib:IsInRegion(self.char.PrimaryPart.Position, workspace:WaitForChild("MapComponents").Zones:GetChildren())
		if region then self.char:SetAttribute("CurrentRegion", region.Name) end
	end
	Spawn(charCurrentZone)

	---// Listening events
	local playerData = self.playerData
	HarukaLib:Hydrate(self.humanoid, {
		["Touched"] = function(hit: BasePart)
			if not self then return end --// Reset issue

			if hit:HasTag("IsZone") then self.char:SetAttribute("CurrentRegion", hit.Name) end
		end
	})
	HarukaLib:Hydrate(plr, {
		["Attr-EXP"] = function(exp: number)
			playerData.EXP[1]:set(exp)
			playerData.EXP[2]:set(floor(Fusion.peek(plr:GetAttribute("Levels")) ^ 1.85) + 60)
		end,
		["Attr-Levels"] = function(level: number)
			playerData.Levels:set(level)
			playerData.EXP[2]:set(floor(level ^ 1.85) + 60)
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
		end
	})
	local charClassInfo = self.charClassInfo
	HarukaLib:Hydrate(self.char, {
		["Attr-Combo"] = function(combo: number)
			charClassInfo.Warrior:set(combo)

            if combo <= 0 then return end

			local bar = Fusion.peek(self.UI).CenterBG.WarriorStyle.BarBG.TweenBar :: Frame
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

		["Attr-InCombat"] = function(newState: boolean)
			self.charStatsDict.IsInCombat:set(newState)
		end
	})

	local function _clearGarbage()
		UI:Destroy()

		ClientUtil:FreezePlayerControls("Unfreeze")

		CAS:UnbindAction("ChangeMobTargetLAlt")
		CAS:UnbindAction("ChangeMobTargetRAlt")

		Events.EquipItems:DisconnectAll()
		Events.GiveDrop:DisconnectAll()
		Events.LevelUp:DisconnectAll()
		Events.NPCChat:DisconnectAll()

		Signals.NPCChat:DisconnectAll()
		Signals.ExCategoryOpened:DisconnectAll()

		self.Empty()

		self = nil
	end
	self.humanoid.Died:Once(_clearGarbage)
end
