--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Bin = require(RepS.Modules.Packages.Bin)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local DeviceGetter = require(RepS.Modules.Packages.DeviceGetter)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local ClassFrame = require(RepS.Modules.UI.Views.ClassFrame)
local ChatFrame = require(RepS.Modules.UI.Views.ChatFrame)
local ItemAcquiredFrame = require(RepS.Modules.UI.Views.ItemAcquiredFrame)
local LevelUpVFXFrame = require(RepS.Modules.UI.Views.LevelUpVFXFrame)
local LocationTitleFrame = require(RepS.Modules.UI.Views.LocationTitleFrame)
local PromptsFrame = require(RepS.Modules.UI.Views.PromptsFrame)
local PlayerEffectsFrame = require(RepS.Modules.UI.Views.PlayerEffectsFrame)
local QuestFrame = require(RepS.Modules.UI.Views.QuestFrame)
local StatsTextsFrame = require(RepS.Modules.UI.Views.StatsTextsFrame)

local CombatStyle = require(RepS.Modules.UI.Components.CombatStyle)
local StatBar = require(RepS.Modules.UI.Components.StatBar)

local Children, New, Value, AttributeChange, Tween, Computed, Hydrate, OnChange, peek =
	Fusion.Children,
	Fusion.New,
	Fusion.Value,
	Fusion.AttributeChange,
	Fusion.Tween,
	Fusion.Computed,
	Fusion.Hydrate,
	Fusion.OnChange,
	Fusion.peek

local AdventurerStats = {}
AdventurerStats.__index = AdventurerStats

local wait = task.wait
local floor, clamp = math.floor, math.clamp
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until plr.PlayerGui:WaitForChild("Backpack", 999)

	local self = setmetatable({}, AdventurerStats)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	self.inventory = plr:WaitForChild("Inventory", 999)
	self.charData = self.char:WaitForChild("CharStats", 999)
	self.humanoid = self.char.Humanoid

	self.UI, self.classInfo, self.skillInfo, self.classFrame = Value(), Value(), Value(), Value()

	self.playerData = {
		EXP = {
			Value(plr:GetAttribute("EXP")),
			Value(floor(plr:GetAttribute("Levels") ^ 1.85) + 60),
		},
		Class = Value(plr:GetAttribute("Class")),
		Levels = Value(plr:GetAttribute("Levels")),
		Gold = Value(HarukaLib:NumberConvert(plr:GetAttribute("Gold"), "%.1f")),
		RP = Value(HarukaLib:NumberConvert(plr:GetAttribute("RP"), "%.1f")),
		LvPoints = Value(plr:GetAttribute("LvPoints"))
	}
	self.charClassInfo = {
		Warrior = { Val = Value(0), UI = Value() },
		Archer = { Val = Value(0), UI = Value() },
		Wizard = { Val = Value(0), UI = Value() },
		Knight = { Val = Value(0), UI = Value() },
		Rogue = { Val = Value(0), UI = Value() }
	}
	self.charStatsDict = {
		HP = { Value(self.char.Humanoid.Health), Value(self.char.Humanoid.MaxHealth) },

		MonsterAmount = Value({}),
		IsInCombat = Value(false),
		EffectsList = Value({}),
	}
	self.shadowTrans = Value(1)
	self.Add, self.Empty = Bin()

	self.version, self.privateId, self.serverLocation =
		Value(RepS.Package.Version.Value), Value(RepS.Package.PrivateServerId.Value), Value(RepS.Package.ServerLocation.Value)

	Components.ScreenGui({
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
				Position = Tween(Computed(function(use)
					return if use(self.charStatsDict.IsInCombat) then fromScale(0.5, 3) else fromScale(0.5, 1)
				end), AssetBook.TweenInfos.twiceHalfOne),

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),
					New("Frame")({
						Name = "EXPBar",
						BackgroundColor3 = fromRGB(30, 30, 30),
						Position = fromScale(0, 0.8),
						Size = fromScale(1, 0.1),

						[Children] = {
							New("Frame")({
								Name = "Bar",
								BackgroundColor3 = fromRGB(217, 193, 144),
								BackgroundTransparency = 0.2,
								Size = Tween(Computed(function(use)
									local x = clamp(use(self.playerData.EXP[1]) / use(self.playerData.EXP[2]), 0, 1)

									return fromScale(x, 1)
								end), AssetBook.TweenInfos.halfBack),
							}),
						},
					}),
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
					PlayerEffectsFrame(self)
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
				}
			}),
			Components.Frame({
				Name = "CenterBG",
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					LevelUpVFXFrame(self),
					PromptsFrame(self),
					ItemAcquiredFrame(self),
					QuestFrame(self),

					CombatStyle(self, "Warrior"),
					CombatStyle(self, "Archer"),
					CombatStyle(self, "Knight"),
					CombatStyle(self, "Rogue"),
				}
			}),
			Components.Frame({
				Name = "Shadow",
				BackgroundTransparency = Tween(Computed(function(use)
					return use(self.shadowTrans)
				end), AssetBook.TweenInfos.twiceHalf),
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
	CAS:BindAction("ChangeMobTarget", _changeMobTarget, false, Enum.KeyCode.LeftAlt)
	CAS:BindAction("ChangeMobTarget2", _changeMobTarget, false, Enum.KeyCode.RightAlt)

	--- Setups
	local function _autoEquipItems()
		for _, item in self.inventory:GetChildren() do
			if item.Value > 0 and item:GetAttribute("Equipped") then
				Events.EquipItems:Fire(AssetBook.Items.ItemType[item.Name], item:GetAttribute("Slot"), item.Name)
			end
		end
	end
	_autoEquipItems()
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
	charCurrentZone()

	---// Listening events
	local playerData = self.playerData
	Hydrate(self.humanoid)({
		[Fusion.OnEvent("Touched")] = function(hit)
			if hit:HasTag("IsZone") then self.char:SetAttribute("CurrentRegion", hit.Name) end
		end
	})
	Hydrate(plr)({
		[AttributeChange("EXP")] = function(exp: number)
			playerData.EXP[1]:set(exp)
			playerData.EXP[2]:set(floor(peek(plr:GetAttribute("Levels")) ^ 1.85) + 60)
		end,
		[AttributeChange("Levels")] = function(level: number)
			playerData.Levels:set(level)
			playerData.EXP[2]:set(floor(level ^ 1.85) + 60)
		end,
		[AttributeChange("Class")] = function(class: string)
			playerData.Class:set(class)
		end,
		[AttributeChange("Gold")] = function(gold: number)
			playerData.Gold:set(HarukaLib:NumberConvert(gold, "%.1f"))
		end,
		[AttributeChange("RP")] = function(rep: number)
			playerData.RP:set(HarukaLib:NumberConvert(rep, "%.1f"))
		end,
		[AttributeChange("LvPoints")] = function(lvPoints: number)
			playerData.LvPoints:set(lvPoints)
		end
	})
	Hydrate(RepS.Package.ServerLocation)({
		[OnChange("Value")] = function(newLocation: string)
			self.serverLocation:set(newLocation)
		end
	})
	Hydrate(RepS.Package.PrivateServerId)({
		[OnChange("Value")] = function(newId: string)
			self.privateId:set(newId)
		end
	})
	Hydrate(RepS.Package.Version)({
		[OnChange("Value")] = function(newVersion: string)
			self.version:set(newVersion)
		end
	})

	local function _clearGarbage()
		peek(self.UI):Destroy()

		ClientUtil:FreezePlayerControls("Unfreeze")

		CAS:UnbindAction("ChangeMobTarget")
		CAS:UnbindAction("ChangeMobTarget2")

		Events.EquipItems:DisconnectAll()
		Events.RefreshBackpack:DisconnectAll()
		Events.GiveDrop:DisconnectAll()
		Events.LevelUp:DisconnectAll()
		Events.NPCChat:DisconnectAll()

		Signals.NPCChat:DisconnectAll()
		Signals.ExCategoryOpened:DisconnectAll()

		self.Empty()
	end
	self.humanoid.Died:Once(_clearGarbage)
end
