--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerMenuPinia)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)

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

					ExCategoryTitle("Menu", self),
					ExCategoryBottomBtns("Left", self, {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						FilterButton("Guild", self),
						FilterButton("Packs", self),
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
			playerData.EXP[2]:set(Formula.EXP(plr:GetAttribute("Levels")))
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

	local classUnlocksListener = {}
	for class: string, _ in AssetBook.ClassInfo do
		classUnlocksListener["Attr-CLASS_UNLOCK_"..class] = function(unlocked: boolean)
			playerData.ClassUnlocks[class]:set(unlocked)
		end
	end
	table.insert(scope, HarukaLib:Hydrate(plr, classUnlocksListener))

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")
		plr:SetAttribute("CurrentMenu", "None")

		Fusion.doCleanup(self.scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
