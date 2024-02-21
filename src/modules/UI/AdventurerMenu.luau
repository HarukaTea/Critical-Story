--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local BottomBtns = require(RepS.Modules.UI.Components.BottomBtns)
local BGTitle = require(RepS.Modules.UI.Components.BGTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonMenu)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)
local PartyFrame = require(RepS.Modules.UI.Views.PartyFrame)

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu

local wait = task.wait

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")

	local self = setmetatable({}, AdventurerMenu)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	self.UI = Fusion.Value()

	Components.ScreenGui({
		Name = "AdventurerMenu",
		Parent = plr.PlayerGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		[Fusion.Ref] = self.UI,

		[Fusion.Children] = {
			Components.Frame({
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Fusion.Children] = {
					CharacterFrame(self),
					SettingsFrame(self),
					PartyFrame(self),

					BGTitle("Menu", self),
					BottomBtns("Left", {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						FilterButton("Party", self)
					}, self),
					BottomBtns("Right", {
						FilterButton("Disband", self)
					}, self),
				}
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
		self.plrGui.AdventurerStats.Enabled = state
		self.plrGui.PlayerList.Enabled = state

		workspace.CurrentCamera.UIBlur.Enabled = not state
	end
	local function _setVisible(curUI: string, ui: ScreenGui)
		plr:SetAttribute("CurrentMenu", curUI)

		_setExVisibleState(ui, if curUI == "None" then false else true)
		_setOthersVisibleState(if curUI == "None" then true else false)
	end
	local function _openMenu(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end
		if not plr:GetAttribute("CurrentMenu") then plr:SetAttribute("CurrentMenu", "None") end

		local menuFrame, backpackFrame = Fusion.peek(self.UI), self.plrGui.Backpack

		if plr:GetAttribute("CurrentMenu") == "None" then
			_setVisible("Menu", menuFrame)

		elseif plr:GetAttribute("CurrentMenu") == "Menu" then
			_setVisible("None", menuFrame)

		elseif plr:GetAttribute("CurrentMenu") == "Backpack" then
			plr:SetAttribute("CurrentMenu", "Menu")

			_setExVisibleState(backpackFrame, false)
			_setExVisibleState(menuFrame, true)
		end
	end
	CAS:BindAction("OpenMenu", _openMenu, false, Enum.KeyCode.C)

	--// Setups
	if not plr:GetAttribute("MenuSetups") then
		plr:SetAttribute("MenuSetups", true)
		plr:SetAttribute("CombatMode", "Solo")
		plr:SetAttribute("Musics", true)
		plr:SetAttribute("SFXs", true)
		plr:SetAttribute("PotatoMode", false)
		plr:SetAttribute("PlayerList", true)
		plr:SetAttribute("InviteAccess", true)
	end

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")

		Fusion.peek(self.UI):Destroy()
		plr:SetAttribute("CurrentMenu", "None")
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
