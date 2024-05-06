--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Pinia = require(RepS.Modules.UI.Pinia.BackpackPinia)

local BackpackItemList = require(RepS.Modules.UI.Views.BackpackItemList)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonBackpack)

local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)

local Children = Fusion.Children

local Backpack = {}
Backpack.__index = Backpack
Backpack.__type = "Backpack"

local wait = task.wait
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local fontFromName = Font.fromName

return function(plr: Player)
	local self = setmetatable({}, Backpack)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local UI = Components.ScreenGui({
		Name = "Backpack",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,

		[Children] = {
			Components.Frame({
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Children] = {
					ExCategoryTitle("Backpack", self),
					ExCategoryBottomBtns("Left", {
						FilterButton("Passive", self),
						FilterButton("Active", self),
						FilterButton("Others", self),
					}),
					ExCategoryBottomBtns("Right", {
						FilterButton("Equip", self),
						FilterButton("Pin", self),
					}),

					Components.Frame({
						Name = "ItemBG",
						Position = fromScale(0.375, 0.567),
						Size = fromScale(0.71, 0.662),
						ClipsDescendants = true,

						[Children] = {
							BackpackItemList(self)
						},
					}),

					ItemDescFrame(self),

					Components.ImageLabel({
						Name = "EmptySymbol",
						Size = fromScale(0.1, 0.255),
						Position = fromScale(0.45, 0.42),
						Image = "rbxassetid://2970814599",
						ImageColor3 = fromRGB(129, 129, 129),
						ImageTransparency = 0.8,

						Visible = Fusion.Computed(function(use)
							return use(self.noItemsShow)
						end),

						[Children] = {
							Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 1.004 }),
							Components.TextLabel({
								Name = "What",
								Position = fromScale(0.85, -0.2),
								Size = fromScale(0.6, 0.6),
								FontFace = fontFromName("GothamSSm", Enum.FontWeight.Bold),
								TextColor3 = fromRGB(129, 129, 129),
								TextTransparency = 0.6,
								Text = "?",
								Rotation = 10,
							}),
						},
					}),
				},
			}),
			Components.Frame({
				Name = "Shadow",
				BackgroundTransparency = 0.15,
				ZIndex = 0,
				Visible = false,
			}),
		},
	})
	repeat wait() until plr.PlayerGui:WaitForChild("AdventurerMenu", 999)

	---// Actions
	local function _openBackpack(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		ClientUtil:OpenUI(plr, "Backpack")
	end
	CAS:BindAction("OpenBackpack", _openBackpack, false, Enum.KeyCode.B)

	---// listening events
	HarukaLib:Hydrate(self.inventory, {
		["ChildAdded"] = function()
			wait()
			self.items:set(self.inventory:GetChildren())
		end,
		["ChildRemoved"] = function()
			if not plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

			wait()
			self.items:set(self.inventory:GetChildren())
		end
	})

	--// Connections
	local function checkIfOpened()
		if UI.BG.Visible then ClientUtil:OpenUI(plr, "Backpack", true) end
	end
	HarukaLib:Hydrate(self.char, {
		["Attr-InCombat"] = function(state: boolean)
			if state then checkIfOpened() end
		end
	})

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenBackpack")

		UI:Destroy()
		plr:SetAttribute("CurrentMenu", "None")

		self.itemSlotClicked:Destroy()

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
