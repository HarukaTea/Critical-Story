--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local BottomBtns = require(RepS.Modules.UI.Components.BottomBtns)
local BGTitle = require(RepS.Modules.UI.Components.BGTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButton)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)

local Value, Children, New, AttributeChange = Fusion.Value, Fusion.Children, Fusion.New, Fusion.AttributeChange

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu

local fromScale = UDim2.fromScale
local wait = task.wait

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")

	local self = setmetatable({}, AdventurerMenu)

	self.plr = plr
	self.plrGui = plr.PlayerGui

	self.UI = Value()
	self.btnsFrame = { Left = Value(), Right = Value() }
	self.chosenFilter = Value("All")

	self.playerData = {
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		DMG = Value(plr:GetAttribute("DmgPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Mana = Value(plr:GetAttribute("ManaPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Gold = Value(plr:GetAttribute("Gold"))
	}
	self.playerSettings = {
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PartyCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true)
	}

	self.potatoStoreParts = {}

	Components.ScreenGui({
		Name = "AdventurerMenu",
		Parent = plr.PlayerGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		[Fusion.Ref] = self.UI,

		[Children] = {
			Components.Frame({
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Children] = {
					BGTitle("Menu", self),
					BottomBtns("Left", {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						-- FilterButton("Donation", self),
						-- FilterButton("Guild", self),
					}, self),

					CharacterFrame(self),
					SettingsFrame(self),

					Components.Frame {
						Name = "Donation",
						Position = fromScale(0.496, 0.567),
						Size = fromScale(0.944, 0.627),

						[Children] = {
							New "UIAspectRatioConstraint" { AspectRatio = 3.856 },
						}
					},
					Components.Frame {
						Name = "Guild",
						Position = fromScale(0.496, 0.567),
						Size = fromScale(0.944, 0.627),

						[Children] = {
							New "UIAspectRatioConstraint" { AspectRatio = 3.856 },
						}
					},
				},
				[Fusion.Attribute("CurrentEx")] = "None",
			}),
			Components.Frame({
				Name = "Shadow",
				BackgroundTransparency = 0.15,
				Visible = false,
			}),
		},
	})

	--// Action bindings
	local function _setExVisibleState(ui: ScreenGui, state: boolean)
		ui.BG.Visible = state
		ui.Shadow.Visible = state
	end
	local function _setOthersVisibleState(state: boolean)
		self.plrGui.AdventurerStats.BG.Visible = state
		self.plrGui.PlayerList.Enabled = state

		workspace.CurrentCamera.UIBlur.Enabled = not state
	end
	local function _setVisible(curUI: string, ui: ScreenGui)
		Fusion.peek(self.UI).BG:SetAttribute("CurrentEx", curUI)

		_setExVisibleState(ui, if curUI == "None" then false else true)
		_setOthersVisibleState(if curUI == "None" then true else false)
	end
	local function _openMenu(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		local menuFrame, backpackFrame = Fusion.peek(self.UI), self.plrGui.Backpack

		if menuFrame.BG:GetAttribute("CurrentEx") == "None" then
			_setVisible("Menu", menuFrame)

		elseif menuFrame.BG:GetAttribute("CurrentEx") == "Menu" then
			_setVisible("None", menuFrame)

		elseif menuFrame.BG:GetAttribute("CurrentEx") == "Backpack" then
			menuFrame.BG:SetAttribute("CurrentEx", "Menu")

			_setExVisibleState(backpackFrame, false)
			_setExVisibleState(menuFrame, true)
		end
	end
	CAS:BindAction("OpenMenu", _openMenu, false, Enum.KeyCode.X)

	local function _togglePlayerList(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		plr:SetAttribute("PlayerList", not plr:GetAttribute("PlayerList"))
	end
	CAS:BindAction("TogglePlayerList", _togglePlayerList, false, Enum.KeyCode.Tab)

	--// Setups
	plr:SetAttribute("CombatMode", "Solo")
	plr:SetAttribute("Musics", true)
	plr:SetAttribute("SFXs", true)
	plr:SetAttribute("PotatoMode", false)
	plr:SetAttribute("PlayerList", true)

	--- listening events
	local playerData, playerSettings = self.playerData, self.playerSettings
	Fusion.Hydrate(plr)({
		[AttributeChange("Levels")] = function(level)
			playerData.Levels:set(level)
		end,
		[AttributeChange("LvPoints")] = function(point)
			playerData.LvPoints:set(point)
		end,
		[AttributeChange("DmgPoints")] = function(point)
			playerData.DMG:set(point)
		end,
		[AttributeChange("HealthPoints")] = function(point)
			playerData.Health:set(point)
		end,
		[AttributeChange("ManaPoints")] = function(point)
			playerData.Mana:set(point)
		end,
		[AttributeChange("ShieldPoints")] = function(point)
			playerData.Shield:set(point)
		end,
		[AttributeChange("MagicPoints")] = function(point)
			playerData.Magic:set(point)
		end,

		[AttributeChange("Gold")] = function(gold)
			playerData.Gold:set(gold)
		end,
		[AttributeChange("Musics")] = function(state)
			playerSettings.Musics:set(state)

			SoundService.Musics.Volume = if state then 1 else 0
		end,
		[AttributeChange("SFXs")] = function(state)
			playerSettings.SFXs:set(state)

			SoundService.SFXs.Volume = if state then 1 else 0
		end,
		[AttributeChange("PotatoMode")] = function(state)
			playerSettings.PotatoMode:set(state)
		end,
		[AttributeChange("PlayerList")] = function(state)
			playerSettings.PlayerList:set(state)
		end
	})
end
