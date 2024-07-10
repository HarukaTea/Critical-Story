--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerMenuPinia)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local LogFrame = require(RepS.Modules.UI.Views.LogFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonMenu)

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu
AdventurerMenu.__type = "AdventurerMenu"

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

		[Fusion.Children] = {
			Components.Frame(scope, {
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Fusion.Children] = {
					CharacterFrame(self),
					SettingsFrame(self),
					LogFrame(self),

					ExCategoryTitle("Menu", self),
					ExCategoryBottomBtns("Left", self, {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						FilterButton("Log", self)
					})
				}
			}),

			Components.BGShadow(scope)
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

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")
		plr:SetAttribute("CurrentMenu", "None")

		Fusion.doCleanup(self.scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
