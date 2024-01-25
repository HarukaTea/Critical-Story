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
local PartyFrame = require(RepS.Modules.UI.Views.PartyFrame)

local Value, AttributeChange, Hydrate, peek = Fusion.Value, Fusion.AttributeChange, Fusion.Hydrate, Fusion.peek

local AdventurerMenu = {}
AdventurerMenu.__index = AdventurerMenu

local wait = task.wait
local remove, tFind = table.remove, table.find

return function(plr: Player)
	repeat wait() until plr:GetAttribute("PlayerDataLoaded")

	local self = setmetatable({}, AdventurerMenu)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	self.UI, self.partyInvList, self.partyMembersList = Value(), Value(), Value()
	self.btnsFrame = { Left = Value(), Right = Value() }
	self.chosenFilter = Value("All")

	local camera = workspace.CurrentCamera
	self.absCamSize = Value({ camera.ViewportSize.X * 0.944 * 0.579, camera.ViewportSize.Y * 0.627 * 0.883 })
	self.absCellSize = Value({ peek(self.absCamSize)[1] * 0.48, peek(self.absCamSize)[2] * 0.15 })
	self.absSize = { Value(0), Value(0) }
	self.absContentSize = { Value(0), Value(0) }

	self.partyMembers = Value({})

	local char = self.char
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
	self.charData = {
		DMG = Value(char:GetAttribute("Damage")),
		Magic = Value(char:GetAttribute("Magic")),
		Mana = Value(char:GetAttribute("MaxMana")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth)
	}
	self.playerSettings = {
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PartyCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true),
		InviteAccess = Value(true)
	}
	self.potatoStoreParts = {}

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
					BGTitle("Menu", self),
					BottomBtns("Left", {
						FilterButton("Character", self),
						FilterButton("Settings", self),
						FilterButton("Party", self)
						-- FilterButton("Donation", self),
						-- FilterButton("Guild", self),
					}, self),

					CharacterFrame(self),
					SettingsFrame(self),
					PartyFrame(self)
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
		self.plrGui.AdventurerStats.BG.Visible = state
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
	CAS:BindAction("OpenMenu", _openMenu, false, Enum.KeyCode.X)

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
	self.absSize[1]:set(peek(self.partyInvList).AbsoluteSize.Y)
	self.absContentSize[1]:set(peek(self.partyInvList).UIListLayout.AbsoluteContentSize.Y)
	self.absSize[2]:set(peek(self.partyMembersList).AbsoluteSize.Y)
	self.absContentSize[2]:set(peek(self.partyMembersList).UIGridLayout.AbsoluteContentSize.Y)

	--- listening events
	local playerData, playerSettings, charData = self.playerData, self.playerSettings, self.charData
	Hydrate(plr)({
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
		end,
		[AttributeChange("InviteAccess")] = function(state)
			playerSettings.InviteAccess:set(state)
		end
	})
	Hydrate(char)({
		[AttributeChange("Damage")] = function(dmg)
			charData.DMG:set(dmg)
		end,
		[AttributeChange("Magic")] = function(magic)
			charData.Magic:set(magic)
		end,
		[AttributeChange("MaxMana")] = function(mana)
			charData.Mana:set(mana)
		end,
		[AttributeChange("MaxShield")] = function(shield)
			charData.Shield:set(shield)
		end
	})
	Hydrate(char.Humanoid)({
		[Fusion.OnChange("MaxHealth")] = function(hp)
			charData.Health:set(hp)
		end
	})
	Hydrate(camera)({
		[Fusion.OnChange("ViewportSize")] = function(newSize)
			self.absCamSize:set({ newSize.X * 0.944 * 0.579, newSize.Y * 0.627 * 0.883 })
			self.absCellSize:set({ peek(self.absCamSize)[1] * 0.48, peek(self.absCamSize)[2] * 0.15 })
		end,
	})

	local function _setPartyMembers(added: Folder | ObjectValue, method: string)
		wait()
		if method == "Add" then
			if workspace.MapComponents.Parties:FindFirstChild(plr.Name, true) then
				if added:IsA("ObjectValue") and added.Parent:FindFirstChild(plr.Name) then
					self.partyMembers:set(added.Parent:GetChildren())
				end
			end
		end
		if method == "Remove" then
			if added.Name == plr.Name and added:IsA("ObjectValue") then self.partyMembers:set({}) end
			if added:IsA("ObjectValue") then
				local members = peek(self.partyMembers)
				if tFind(members, added) then
					remove(members, tFind(members, added))
				end

				self.partyMembers:set(members)
			end
		end
		if method == "Refresh" then
			local check = workspace.MapComponents.Parties:FindFirstChild(plr.Name, true)

			if not check then return end

			if check:IsA("Folder") then
				self.partyMembers:set(check:GetChildren())

			elseif check:IsA("ObjectValue") then
				self.partyMembers:set(check.Parent:GetChildren())
			end
		end
	end
	_setPartyMembers(nil, "Refresh")
	Hydrate(workspace:WaitForChild("MapComponents").Parties)({
		[Fusion.OnEvent("DescendantAdded")] = function(added)
			_setPartyMembers(added, "Add")
		end,
		[Fusion.OnEvent("DescendantRemoving")] = function(added)
			_setPartyMembers(added, "Remove")
		end
	})

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenMenu")

		Fusion.peek(self.UI):Destroy()
		plr:SetAttribute("CurrentMenu", "None")
	end
	char.Humanoid.Died:Once(_clearGarbage)
end
