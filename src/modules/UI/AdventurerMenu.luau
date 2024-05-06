--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Pinia = require(RepS.Modules.UI.Pinia.AdventurerMenuPinia)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonMenu)

local CharacterFrame = require(RepS.Modules.UI.Views.CharacterFrame)
local SettingsFrame = require(RepS.Modules.UI.Views.SettingsFrame)

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu
AdventurerMenu.__type = "AdventurerMenu"

local wait = task.wait

return function(plr: Player)
	local self = setmetatable({}, AdventurerMenu)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self) --// Create a storage

	local UI = Components.ScreenGui({
		Name = "AdventurerMenu",
		Parent = plr.PlayerGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,
		[Fusion.Ref] = self.UI,

		[Fusion.Children] = {
			Components.Frame({
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Fusion.Children] = {
					CharacterFrame(self),
					SettingsFrame(self),

					ExCategoryTitle("Menu", self),
					ExCategoryBottomBtns("Left", {
						FilterButton("Character", self),
						FilterButton("Settings", self),
					}),
				}
			}),
			Components.Frame({
				Name = "Shadow",
				BackgroundTransparency = 0.15,
				ZIndex = 0,
				Visible = false,
			}),
		},
	})
	repeat wait() until plr.PlayerGui:WaitForChild("Backpack", 999)

	--// Action bindings
	local function _openMenu(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		ClientUtil:OpenUI(plr, "AdventurerMenu")
	end
	CAS:BindAction("OpenMenu", _openMenu, false, Enum.KeyCode.C)

	--// Connections
	local function checkIfOpened()
		if UI.BG.Visible then ClientUtil:OpenUI(plr, "AdventurerMenu", true) end
	end
	Fusion.Hydrate(self.char)({
		[Fusion.AttributeChange("InCombat")] = function(state: boolean)
			if state then checkIfOpened() end
		end
	})

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")

		UI:Destroy()
		plr:SetAttribute("CurrentMenu", "None")

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
