--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local PPS = game:GetService("ProximityPromptService")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Bin = require(RepS.Modules.Packages.Bin)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local ClassFrame = require(RepS.Modules.UI.Views.ClassFrame)
local ItemAcquiredFrame = require(RepS.Modules.UI.Views.ItemAcquiredFrame)
local LevelUpVFXFrame = require(RepS.Modules.UI.Views.LevelUpVFXFrame)
local LocationTitleFrame = require(RepS.Modules.UI.Views.LocationTitleFrame)
local MonsterHPFrame = require(RepS.Modules.UI.Views.MonsterHPFrame)
local PromptsFrame = require(RepS.Modules.UI.Views.PromptsFrame)

local CombatStyle = require(RepS.Modules.UI.Components.CombatStyle)
local StatBar = require(RepS.Modules.UI.Components.StatBar)

local Children, New, Value, Hydrate, AttributeChange, OnEvent, peek =
	Fusion.Children, Fusion.New, Fusion.Value, Fusion.Hydrate, Fusion.AttributeChange, Fusion.OnEvent, Fusion.peek

local AdventurerStats = {}
AdventurerStats.__index = AdventurerStats

local wait, cancel = task.wait, task.cancel
local insert, remove, tFind = table.insert, table.remove, table.find
local floor, clamp = math.floor, math.clamp
local sFind, format, match = string.find, string.format, string.match
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

--[[
	Send a request to server to use an item with the given slot, 1s inner CD
]]
function AdventurerStats:UseItem(slot: number)
	local itemSlot = peek(self.activeList[slot + 1])
	local activeInnerCDList = self.activeInnerCDList

	if not itemSlot:GetAttribute("InCD") and itemSlot:GetAttribute("Equipped") then
		if activeInnerCDList[slot + 1] then return end

		activeInnerCDList[slot + 1] = true

		if slot == 0 then
			Events.CastClassSkill:Fire()
		else
			Events.UseItem:Fire(itemSlot:GetAttribute("ItemEquipped"))
		end

		wait(1)
		activeInnerCDList[slot + 1] = false
	end
end

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
	self.humanoid = self.char:WaitForChild("Humanoid")

	self.UI, self.classInfo, self.skillInfo, self.classFrame = Value(), Value(), Value(), Value()

	local char, humanoid = self.char, self.humanoid

	self.activeList = { Value(), Value(), Value(), Value() }
	self.charStatsDict = {
		HP = { Value(humanoid.Health), Value(humanoid.MaxHealth) },
		MP = { Value(char:GetAttribute("Mana")), Value(char:GetAttribute("MaxMana")) },
		DEF = { Value(char:GetAttribute("Shield")), Value(char:GetAttribute("MaxShield")) },
		DEFRepairing = Value(false), HPHealing = Value(false),

		MonsterAmount = Value({}),
		IsInCombat = Value(false),
		EffectsList = Value({}),

		PlayerData = {
			EXP = {
				Value(plr:GetAttribute("EXP")),
				Value(floor(plr:GetAttribute("Levels") ^ 1.85) + 60),
			},
			Class = Value(plr:GetAttribute("Class")),
			Levels = Value(plr:GetAttribute("Levels")),
			DMG = Value(char:GetAttribute("Damage")),
			Magic = Value(char:GetAttribute("Magic")),
			Gold = Value(HarukaLib:NumberConvert(plr:GetAttribute("Gold"), "%.1f")),
			RP = Value(HarukaLib:NumberConvert(plr:GetAttribute("RP"), "%.1f")),
		},
	}
	self.activeInnerCDList = { false, false, false, false }
	self.activeCDRotationList = { Value(0), Value(0), Value(0), Value(0), Value(0) }
	self.activeCDText = { Value(""), Value(""), Value(""), Value(""), Value("") }

	self.monsterHPPos, self.monsterTargetingPos = Value(fromScale(0.9, -2.7)), Value(fromScale(-0.15, 0))
	self.newAddedItems = Value({})

	self.shadowTrans = Value(1)
	self.levelUpShown, self.levelUpTitleShown, self.levelUpPos = Value(false), Value(false), Value(fromScale(0.55, 0))

	self.locationInfo = {
		Thread = nil,
		Name = Value(""),
		Desc = Value(""),
		Shown = Value(false),
		OverallTrans = Value(1),
		OverallStrokeTrans = Value(1),
		HorizonLineSize = Value(fromScale(0.25, 0.07))
	}
	self.promptsList = Value({})
	self.charClassInfo = {
		Warrior = { Val = Value(0), UI = Value() },
		Archer = { Val = Value(0), UI = Value() },
		Wizard = { Val = Value(0), UI = Value() },
		Knight = { Val = Value(0), UI = Value() },
		Rogue = { Val = Value(0), UI = Value() }
	}

	self.Add, self.Empty = Bin()

	Components.ScreenGui({
		Name = "AdventurerStats",
		Parent = self.plrGui,
		[Fusion.Ref] = self.UI,

		[Children] = {
			Components.Frame({
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Position = fromScale(0.5, 1),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

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
								BackgroundColor3 = fromRGB(236, 204, 104),
								BackgroundTransparency = 0.2,
								Size = Fusion.Tween(Fusion.Computed(function(use)
									local x = clamp(use(self.charStatsDict.PlayerData.EXP[1]) / use(self.charStatsDict.PlayerData.EXP[2]), 0, 1)

									return fromScale(x, 1)
								end), AssetBook.TweenInfos.halfBack),
							}),
						},
					}),
					Components.Frame({
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.4),

						[Children] = {
							New("UIListLayout")({
								Padding = udNew(0.01, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							StatBar("DEF", self),
							StatBar("HP", self),
							StatBar("MP", self),
						},
					}),

					ClassFrame(self),
					ItemAcquiredFrame(self),
					MonsterHPFrame(self)
				},
			}),
			Components.Frame({
				Name = "TopBG",
				AnchorPoint = v2New(0.5, 0),
				Position = ud2New(0.5, 0, 0, 58),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New "UIAspectRatioConstraint" { AspectRatio = 25.697 },

					LocationTitleFrame(self)
				}
			}),
			Components.Frame({
				Name = "CenterBG",
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Children] = {
					New "UIAspectRatioConstraint" { AspectRatio = 25.697 },

					LevelUpVFXFrame(self),
					PromptsFrame(self),

					CombatStyle(self, "Warrior"),
					CombatStyle(self, "Archer"),
					CombatStyle(self, "Wizard"),
					CombatStyle(self, "Knight"),
					CombatStyle(self, "Rogue")
				}
			}),
			Components.Frame({
				Name = "Shadow",
				BackgroundTransparency = Fusion.Tween(Fusion.Computed(function(use)
					return use(self.shadowTrans)
				end), AssetBook.TweenInfos.twiceHalf),
			})
		},
	})

	--// Action bindings
	local function _useSkill(id: string, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		if id == "UseQSkill" then
			self:UseItem(1)

		elseif id == "UseWSkill" then
			self:UseItem(2)

		elseif id == "UseESkill" then
			self:UseItem(3)

		elseif id == "UseFSkill" then
			self:UseItem(0)
		end
	end
	CAS:BindAction("UseQSkill", _useSkill, false, Enum.KeyCode.One)
	CAS:BindAction("UseWSkill", _useSkill, false, Enum.KeyCode.Two)
	CAS:BindAction("UseESkill", _useSkill, false, Enum.KeyCode.Three)
	CAS:BindAction("UseFSkill", _useSkill, false, Enum.KeyCode.F)

	--- Setups
	local function _autoEquipItems()
		for _, item in self.inventory:GetChildren() do
			if item.Value > 0 and item:GetAttribute("Equipped") then
				Events.EquipItems:Fire(AssetBook.Items.ItemType[item.Name], item:GetAttribute("Slot"), item.Name)
			end
		end
	end
	_autoEquipItems()

	---// Listening events
	local charStatsDict = self.charStatsDict
	local charClassInfo = self.charClassInfo
	local function _showCurrentLocation(location: string)
		local locationInfo = self.locationInfo

		if locationInfo.Thread then cancel(locationInfo.Thread) end

		wait()
		locationInfo.Thread = spawn(function()
			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
			locationInfo.Shown:set(true)

			wait(0.3)
			locationInfo.OverallStrokeTrans:set(0.3)
			locationInfo.OverallTrans:set(0)

			locationInfo.Name:set(AssetBook.LocationInfo.Name[location])
			locationInfo.Desc:set(AssetBook.LocationInfo.Desc[location])

			wait(0.1)
			locationInfo.HorizonLineSize:set(fromScale(0, 0.07))

			wait(2)
			locationInfo.OverallStrokeTrans:set(1)
			locationInfo.OverallTrans:set(1)

			wait(1)
			locationInfo.Shown:set(false)
			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
		end)
	end
	Hydrate(self.char)({
		[AttributeChange("Mana")] = function(mana)
			charStatsDict.MP[1]:set(mana)
		end,
		[AttributeChange("MaxMana")] = function(mana)
			charStatsDict.MP[2]:set(mana)
		end,
		[AttributeChange("Shield")] = function(shield)
			charStatsDict.DEF[1]:set(shield)
		end,
		[AttributeChange("MaxShield")] = function(shield)
			charStatsDict.DEF[2]:set(shield)
		end,
		[AttributeChange("Damage")] = function(dmg)
			charStatsDict.PlayerData.DMG:set(dmg)
		end,
		[AttributeChange("Magic")] = function(magic)
			charStatsDict.PlayerData.Magic:set(magic)
		end,

		--- ui state related
		[AttributeChange("Repairing")] = function(state)
			charStatsDict.DEFRepairing:set(state)
		end,
		[AttributeChange("Healing")] = function(state)
			charStatsDict.HPHealing:set(state)
		end,
		[AttributeChange("InCombat")] = function(state)
			charStatsDict.IsInCombat:set(state)
		end,
		[AttributeChange("CurrentRegion")] = function(region)
			if not region or region == "" then return end

			_showCurrentLocation(region)
		end,

		--- class related
		[AttributeChange("Combo")] = function(combo)
			if combo <= 0 then
				charClassInfo.Warrior.Val:set(combo)
				return
			end

			local tagUI = peek(charClassInfo.Warrior.UI)

			charClassInfo.Warrior.Val:set(combo)

			TS:Create(tagUI.BarBG.Bar, AssetBook.TweenInfos.twiceHalf, { Size = fromScale(1, 1) }):Play()
			wait(0.2)
			TS:Create(tagUI.BarBG.Bar, AssetBook.TweenInfos.threeHalfOne, { Size = fromScale(0, 1) }):Play()
		end,
		[AttributeChange("Arrows")] = function(arrows)
			charClassInfo.Archer.Val:set(arrows)
		end,
		[AttributeChange("WizardCasted")] = function(casted)
			charClassInfo.Wizard.Val:set(casted)
		end,
		[AttributeChange("Guard")] = function(guarded)
			charClassInfo.Knight.Val:set(guarded)
		end,
		[AttributeChange("RogueCritical")] = function(criChance)
			charClassInfo.Rogue.Val:set(criChance)
		end
	})

	local function _setEffectsChildren()
		wait()
		self.charStatsDict.EffectsList:set(self.charData.EffectsList:GetChildren())
	end
	Hydrate(self.charData.EffectsList)({
		[OnEvent("ChildAdded")] = _setEffectsChildren,
		[OnEvent("ChildRemoved")] = _setEffectsChildren
	})


	Hydrate(self.humanoid)({
		[Fusion.OnChange("Health")] = function(health)
			charStatsDict.HP[1]:set(health)
		end,
		[Fusion.OnChange("MaxHealth")] = function(health)
			charStatsDict.HP[2]:set(health)
		end,
		[OnEvent("Touched")] = function(hit)
			if hit:GetAttribute("IsZone") then self.char:SetAttribute("CurrentRegion", hit.Name) end
		end
	})

	Hydrate(plr)({
		[AttributeChange("EXP")] = function(exp)
			charStatsDict.PlayerData.EXP[1]:set(exp)
			charStatsDict.PlayerData.EXP[2]:set(floor(peek(plr:GetAttribute("Levels")) ^ 1.85) + 60)
		end,
		[AttributeChange("Levels")] = function(level)
			charStatsDict.PlayerData.Levels:set(level)
			charStatsDict.PlayerData.EXP[2]:set(floor(level ^ 1.85) + 60)
		end,
		[AttributeChange("Class")] = function(class)
			charStatsDict.PlayerData.Class:set(class)
		end,
		[AttributeChange("Gold")] = function(gold)
			charStatsDict.PlayerData.Gold:set(HarukaLib:NumberConvert(gold, "%.1f"))
		end,
		[AttributeChange("RP")] = function(rep)
			charStatsDict.PlayerData.RP:set(HarukaLib:NumberConvert(rep, "%.1f"))
		end,
	})

	local function _equipItem(type: string, slot: string, item: string)
		local itemSlot = peek(self.classFrame)[slot]

		itemSlot:SetAttribute("Equipped", true)
		itemSlot:SetAttribute("ItemEquipped", item)

		if type == "Passive" then
			itemSlot.Hover.Image = AssetBook.Items.ItemImages[item]

		elseif type == "Active" then
			itemSlot.Icon.Image = AssetBook.Items.ItemImages[item]
			itemSlot.Amount.Text = if self.inventory[item].Value > 1 then "x" .. self.inventory[item].Value else ""
		end
	end
	Events.EquipItems:Connect(_equipItem)

	local function __findSlotByItemId(item: string): string
		for _, element in peek(self.classFrame):GetChildren() do
			if sFind(element.Name, "Active") then
				if element:GetAttribute("ItemEquipped") == item then
					return element.Name
				end
			end
		end

		return "None"
	end
	local function _applyCDToSlot(cd: number, item: string)
		local slot, classFrame, activeCDRotationList, activeCDText =
			__findSlotByItemId(item), peek(self.classFrame), self.activeCDRotationList, self.activeCDText

		--- cancel the cd
		if cd == 0 then
			local itemSlot = item
			if not classFrame:FindFirstChild(itemSlot) then return end

			classFrame[itemSlot]:SetAttribute("InCD", false)
			return
		end

		--- class skills
		if item == "Class" then slot = "ClassSkill" end

		--- final check
		if slot == "None" then return end

		local itemSlot = classFrame[slot]
		local percentage = 0
		local index = if item == "Class" then 1 else tonumber(match(slot, "%d")) + 1

		itemSlot.Cooldown.Visible = true
		itemSlot:SetAttribute("InCD", true)

		for i = cd, 0.1, -0.1 do
			if itemSlot:GetAttribute("InCD") == false then break end

			local pattern = if i > 10 then "%.0f" else "%.1f"
			activeCDText[index]:set(format(pattern, i))

			percentage += 1/(cd * 10)
			activeCDRotationList[index]:set(percentage)

			wait(0.1)
		end

		if not classFrame:FindFirstChild(slot) then return end

		itemSlot.Cooldown.Visible = false
		itemSlot:SetAttribute("InCD", false)
		activeCDRotationList[index]:set(0)
	end
	Events.ItemCD:Connect(_applyCDToSlot)
	Events.CastClassSkill:Connect(_applyCDToSlot)

	local function _refreshEquippedItems()
		local classFrame, inventory = peek(self.classFrame), self.inventory

		for _, element in classFrame:GetChildren() do
			if sFind(element.Name, "Active") then
				element:SetAttribute("Equipped", false)
				element:SetAttribute("ItemEquipped", "")
				element.Amount.Text = ""
				element.Icon.Image = AssetBook.Items.ItemImages.Null

			elseif sFind(element.Name, "Passive") then
				element:SetAttribute("Equipped", false)
				element:SetAttribute("ItemEquipped", "")
				element.Hover.Image = AssetBook.Items.ItemImages.Null
			end
		end

		for _, item in inventory:GetChildren() do
			if item.Value > 0 and AssetBook.Items.ItemType[item.Name] == "Passive" and item:GetAttribute("Equipped") then
				local slot = item:GetAttribute("Slot")
				local itemSlot = classFrame[slot]

				itemSlot.Hover.Image = AssetBook.Items.ItemImages[item.Name]
				itemSlot:SetAttribute("Equipped", true)
				itemSlot:SetAttribute("ItemEquipped", item.Name)
			end
		end

		for _, item in inventory:GetChildren() do
			if item.Value > 0 and AssetBook.Items.ItemType[item.Name] == "Active" and item:GetAttribute("Equipped") then
				local slot = item:GetAttribute("Slot")
				local itemSlot = classFrame[slot]

				itemSlot.Amount.Text = inventory[item.Name].Value > 1 and "x" .. inventory[item.Name].Value or ""
				itemSlot.Icon.Image = AssetBook.Items.ItemImages[item.Name]
				itemSlot:SetAttribute("Equipped", true)
				itemSlot:SetAttribute("ItemEquipped", item.Name)
			end
		end

		for _, itemLabel in self.plrGui.Backpack.BG.ItemBG.Items:GetChildren() do
			if itemLabel:IsA("ImageButton") and inventory:FindFirstChild(itemLabel.Name) then --- items run out also triggers this
				itemLabel.Equipped.Visible = inventory[itemLabel.Name]:GetAttribute("Equipped") and true or false
				itemLabel.Amount.Text = inventory[itemLabel.Name].Value > 1 and "x" .. inventory[itemLabel.Name].Value or ""
			end
		end
	end
	Events.RefreshBackpack:Connect(_refreshEquippedItems)

	local function _giveDrop(item: string)
		local nowAdded = peek(self.newAddedItems)

		insert(nowAdded, item)
		self.newAddedItems:set(nowAdded)

		Spawn(function()
			wait(4)
			local afterAdded = peek(self.newAddedItems)

			remove(afterAdded, tFind(afterAdded, item))
			self.newAddedItems:set(afterAdded)
		end)
	end
	Events.GiveDrop:Connect(_giveDrop)

	local function _showLvlUpVFX()
		self.levelUpShown:set(true)
		self.shadowTrans:set(0.15)

		wait(0.2)
		self.levelUpPos:set(fromScale(0.42, 0))

		wait(0.6)
		self.levelUpTitleShown:set(true)

		wait(1)
		self.levelUpShown:set(false)
		self.levelUpPos:set(fromScale(0.55, 0))
		self.levelUpTitleShown:set(false)
		self.shadowTrans:set(1)
	end
	Events.LevelUp:Connect(_showLvlUpVFX)

	local monsterHPThread
	local function _combatStartSetup(monster: Model)
		if monsterHPThread then cancel(monsterHPThread) end
		if not monster then return end

		self.monsterHPPos:set(fromScale(0.5, -2.7))

		monsterHPThread = spawn(function()
			while true do
				self.monsterTargetingPos:set(fromScale(-0.16, 0))
				wait(0.6)
				self.monsterTargetingPos:set(fromScale(-0.15, 0))
				wait(0.6)
			end
		end)
	end
	local function _combatEndAction()
		if monsterHPThread then cancel(monsterHPThread) end

		self.monsterHPPos:set(fromScale(1.5, -2.7))
	end
	Hydrate(self.char)({
		[AttributeChange("InCombat")] = function(state)
			if state then
				_combatStartSetup(self.charData.TargetMonster.Value)

			elseif not state then
				_combatEndAction()
			end
		end
	})

	local function _addMonster(monster: ObjectValue)
		wait()
		local nowMonsters = peek(self.charStatsDict.MonsterAmount)

		insert(nowMonsters, monster)
		self.charStatsDict.MonsterAmount:set(nowMonsters)
	end
	local function _removeMonster(monster: ObjectValue)
		wait(1)
		local afterMonsters = peek(self.charStatsDict.MonsterAmount)

		remove(afterMonsters, tFind(afterMonsters, monster))
		self.charStatsDict.MonsterAmount:set(afterMonsters)
	end
	Hydrate(self.charData.TargetMonsters)({
		[OnEvent("ChildAdded")] = _addMonster,
		[OnEvent("ChildRemoved")] = _removeMonster
	})

	local function _addPrompt(prompt: ProximityPrompt)
		local nowPrompts = peek(self.promptsList)

		insert(nowPrompts, prompt)
		self.promptsList:set(nowPrompts)
	end
	local function _removePrompt(prompt: ProximityPrompt)
		local afterPrompts = peek(self.promptsList)

		remove(afterPrompts, tFind(afterPrompts, prompt))
		self.promptsList:set(afterPrompts)
	end
	local function _triggerPrompt(prompt: ProximityPrompt)
		workspace.Sounds.SFXs.Interact:Play()

		prompt.Enabled = false
		wait(1)
		local blacklist = { "Chest", "PublicJoin", "PartyJoin" }
		if not tFind(blacklist, prompt.Name) then prompt.Enabled = true end
	end
	self.Add(PPS.PromptShown:Connect(_addPrompt))
	self.Add(PPS.PromptHidden:Connect(_removePrompt))
	self.Add(PPS.PromptTriggered:Connect(_triggerPrompt))

	local function _clearGarbage()
		peek(self.UI):Destroy()

		CAS:UnbindAction("UseQSkill")
		CAS:UnbindAction("UseWSkill")
		CAS:UnbindAction("UseESkill")
		CAS:UnbindAction("UseFSkill")

		Events.EquipItems:DisconnectAll()
		Events.ItemCD:DisconnectAll()
		Events.RefreshBackpack:DisconnectAll()
		Events.GiveDrop:DisconnectAll()
		Events.LevelUp:DisconnectAll()
		Events.CastClassSkill:DisconnectAll()

		self.Empty()
	end
	self.humanoid.Died:Once(_clearGarbage)
end
