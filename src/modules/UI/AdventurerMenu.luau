--!nocheck

local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ClassBook = require(RepS.Modules.Data.ClassBook)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerMenuPinia)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local DonationFrame = require(RepS.Modules.UI.Views.DonationFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)
local QuestsFrame = require(RepS.Modules.UI.Views.QuestListFrame)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonMenu)

local Children = Fusion.Children

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu

local wait = task.wait

return function(plr: Player)
	local self = setmetatable({}, AdventurerMenu)

	self.plr = plr
	self.plrGui = plr:FindFirstChildOfClass("PlayerGui")
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self) --// Create a storage

	local scope = self.scope :: Fusion.Scope
	local UI = Components.ScreenGui(scope, {
		Name = "AdventurerMenu",
		Parent = plr:FindFirstChildOfClass("PlayerGui"),
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Children] = {
					CharacterFrame(self),
					SettingsFrame(self),
					QuestsFrame(self),

					DonationFrame(self),

					ExCategoryTitle("Menu", self),
					ExCategoryBottomBtns("Left", self, {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						FilterButton("Quests", self),
						--FilterButton("Guild", self),
						FilterButton("Donation", self)
					})
				}
			}),

			Components.Frame(scope, {
				Name = "Shadow",
				BackgroundTransparency = 0,
				ZIndex = 0,
				Visible = false,

				[Children] = {
					Fusion.New(scope, "UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.4, 0.65),
							NumberSequenceKeypoint.new(0.6, 0.65),
							NumberSequenceKeypoint.new(1, 0)
						})
					})
				}
			})
		},
	})

	--// Action bindings
	local function _openMenu(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		ClientUtil:OpenUIEx(plr, "AdventurerMenu")
	end
	CAS:BindAction("OpenMenu", _openMenu, false, Enum.KeyCode.C)

	--// Connections
	local function checkIfOpened()
		if UI.BG.Visible then ClientUtil:OpenUIEx(plr, "AdventurerMenu", true) end
	end
	table.insert(scope, HarukaLib:Hydrate(self.char, {
		["Attr-InCombat"] = function(state: boolean)
			if state then checkIfOpened() end
		end
	}))
	table.insert(scope, HarukaLib:Hydrate(plr, {
		["Attr-InChatting"] = function(state: boolean)
			if state then checkIfOpened() end
		end
	}))

	local playerData, charData = self.playerData, self.charData
	table.insert(scope, HarukaLib:Hydrate(plr, {
		["Attr-Class"] = function(class: string)
			playerData.Class:set(class)

			self.classTalents:set(ClassBook.ClassInfo[class].Talents or {})
			self.currentTalent:set({})
			self.currentMaterialsNeeded:set({})
		end,
		["Attr-Levels"] = function(levels: number)
			playerData.Levels:set(levels)
			playerData.EXP[2]:set(Formula.EXP(levels))
		end,
		["Attr-LvPoints"] = function(points: number)
			playerData.LvPoints:set(points)
		end,
		["Attr-DMGPoints"] = function(points: number)
			playerData.DMG:set(points)
		end,
		["Attr-MagicPoints"] = function(points: number)
			playerData.Magic:set(points)
		end,
		["Attr-HealthPoints"] = function(points: number)
			playerData.Health:set(points)
		end,
		["Attr-ManaPoints"] = function(points: number)
			playerData.Mana:set(points)
		end,
		["Attr-ShieldPoints"] = function(points: number)
			playerData.Shield:set(points)
		end,
		["Attr-Gold"] = function(gold: number)
			playerData.Gold:set(gold)
		end,
		["Attr-EXP"] = function(exp: number)
			playerData.EXP[1]:set(exp)
		end,
	}))
	table.insert(scope, HarukaLib:Hydrate(self.char, {
		["Attr-MinDMG"] = function(dmg: number)
			charData.MinDMG:set(dmg)
		end,
		["Attr-MaxDMG"] = function(dmg: number)
			charData.MaxDMG:set(dmg)
		end,
		["Attr-Magic"] = function(magic: number)
			charData.Magic:set(magic)
		end,
		["Attr-MaxShield"] = function(shield: number)
			charData.Shield:set(shield)
		end,
		["Attr-MaxMana"] = function(mana: number)
			charData.Mana:set(mana)
		end,
		["Attr-CriChance"] = function(cri: number)
			charData.CriChance:set(cri)
		end,
		["Attr-CriDMG"] = function(cri: number)
			charData.CriDMG:set(cri)
		end
	}))
	table.insert(scope, HarukaLib:Hydrate(self.char.Humanoid, {
		["Prop-MaxHealth"] = function(maxHP: number)
			charData.Health:set(maxHP)
		end
	}))

	local playerSettings = self.playerSettings
	table.insert(scope, HarukaLib:Hydrate(self.plr, {
		["Attr-CombatMode"] = function(newMode: string)
			playerSettings.PublicCombat:set(newMode == "Public")
		end,
		["Attr-Musics"] = function(state: boolean)
			playerSettings.Musics:set(state)

			SoundService.Musics.Volume = if state then 0.5 else 0
		end,
		["Attr-SFXs"] = function(state: boolean)
			playerSettings.SFXs:set(state)

			SoundService.SFXs.Volume = if state then 0.5 else 0
		end,
		["Attr-PotatoMode"] = function(state: boolean)
			playerSettings.PotatoMode:set(state)

			if state == false then
				for _, child: Instance in workspace.Maps:GetDescendants() do
					if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
						if child:GetAttribute("OriMaterial") then child.Material = child:GetAttribute("OriMaterial") end

						child:SetAttribute("OriMaterial", nil)
					end
				end

			elseif state then
				for _, child: Instance in workspace.Maps:GetDescendants() do
					if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
						child:SetAttribute("OriMaterial", child.Material)

						child.Material = Enum.Material.Plastic
					end
				end
			end
		end,
		["Attr-PlayerList"] = function(state: boolean)
			playerSettings.PlayerList:set(state)
		end,
		["Attr-MapDetails"] = function(state: boolean)
			playerSettings.MapDetails:set(state)

			Signals.EnableMapDetails:Fire(if state then "Enable" else "Disable")
		end,
		["Attr-MapShadows"] = function(state: boolean)
			if state == nil then return end

			playerSettings.MapShadows:set(state)

			for _, child: Instance in workspace:GetDescendants() do
				if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
					child.CastShadow = state
				end
			end
			Lighting.GlobalShadows = state
		end,
		["Attr-TreeOptimizations"] = function(state: boolean)
			playerSettings.TreeOptimizations:set(state)
		end,
		["Attr-HideRole"] = function(state: boolean)
			playerSettings.HideRole:set(state)
		end
	}))

	local classUnlocksListener = {}
	for class: string, _ in ClassBook.ClassInfo do
		classUnlocksListener["Attr-CLASS_UNLOCK_"..class] = function(unlocked: boolean)
			playerData.ClassUnlocks[class]:set(unlocked)
		end
	end
	table.insert(scope, HarukaLib:Hydrate(plr, classUnlocksListener))

	local function updateDonationList()
		wait()
		if not self then return end

		self.donationList:set(workspace.MapComponents.Donations:GetChildren())
	end
	table.insert(scope, workspace.MapComponents.Donations.ChildAdded:Connect(updateDonationList))
	table.insert(scope, workspace.MapComponents.Donations.ChildRemoved:Connect(updateDonationList))
	updateDonationList()

	local function updateQuests()
        wait()
        self.questList:set(plr.Quests:GetChildren())
		self.questRewardsList:set({})
		self.questDesc:set("")
    end
    table.insert(scope, plr.Quests.ChildAdded:Connect(updateQuests))
    table.insert(scope, plr.Quests.ChildRemoved:Connect(updateQuests))
	updateQuests()

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")
		plr:SetAttribute("CurrentMenu", "None")

		Fusion.doCleanup(self.scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
