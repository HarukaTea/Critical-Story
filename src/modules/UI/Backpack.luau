--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Pinia = require(RepS.Modules.UI.Pinia.BackpackPinia)

local BackpackItemList = require(RepS.Modules.UI.Views.BackpackItemList)
local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)

local ExCategoryBottomBtns = require(RepS.Modules.UI.Components.ExCategoryBottomBtns)
local ExCategoryTitle = require(RepS.Modules.UI.Components.ExCategoryTitle)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonBackpack)

local Children = Fusion.Children

local Backpack = {}
Backpack.__index = Backpack

local wait = task.wait
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local fontFromName = Font.fromName

return function(plr: Player)
	local self = setmetatable({}, Backpack)

	self.plr = plr
	self.plrGui = plr:FindFirstChildOfClass("PlayerGui")
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local scope = self.scope :: Fusion.Scope
	local UI = Components.ScreenGui(scope, {
		Name = "Backpack",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Children] = {
					ExCategoryTitle("Backpack", self),
					ExCategoryBottomBtns("Left", self, {
						FilterButton("Passive", self),
						FilterButton("Active", self),
						FilterButton("Material", self),
						FilterButton("Equipment", self),
						FilterButton("Other", self)
					}),
					ExCategoryBottomBtns("Right", self, {
						FilterButton("Equip", self),
						FilterButton("Pin", self),
					}),

					Components.Frame(scope, {
						Name = "ItemBG",
						Position = fromScale(0.375, 0.567),
						Size = fromScale(0.71, 0.662),

						[Children] = {
							BackpackItemList(self)
						},
					}),

					ItemDescFrame(self),

					Components.ImageLabel(scope, {
						Name = "EmptySymbol",
						Size = fromScale(0.1, 0.255),
						Position = fromScale(0.45, 0.42),
						Image = "rbxassetid://2970814599",
						ImageColor3 = fromRGB(129, 129, 129),
						ImageTransparency = 0.8,

						Visible = Fusion.Computed(scope, function(use: Fusion.Use)
							return use(self.noItemsShow)
						end),

						[Children] = {
							Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 1.004 }),
							Components.TextLabel(scope, {
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

			Components.Frame(scope, {
				Name = "Shadow",
				BackgroundTransparency = 0.15,
				ZIndex = 0,
				Visible = false
			})
		},
	})

	---// Actions
	local function _openBackpack(_, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then return end

		ClientUtil:OpenUIEx(plr, "Backpack")
	end
	CAS:BindAction("OpenBackpack", _openBackpack, false, Enum.KeyCode.B)

	--// Setups
	local passiveCheck = false
	for _, item: IntValue in self.inventory:GetChildren() do
		if ItemBook:FindItem(item.Name).Type == "Passive" then passiveCheck = true break end
	end
	self.noItemsShow:set(not passiveCheck)

	---// listening events
	table.insert(scope, self.inventory.ChildAdded:Connect(function()
		wait()
		self.items:set(self.inventory:GetChildren())
	end))
	table.insert(scope, self.inventory.ChildRemoved:Connect(function()
		if not plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

		wait()
		self.items:set(self.inventory:GetChildren())
	end))

	--// Connections
	local function checkIfOpened()
		if UI.BG.Visible then ClientUtil:OpenUIEx(plr, "Backpack", true) end
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
		CAS:UnbindAction("OpenBackpack")
		plr:SetAttribute("CurrentMenu", "None")

		self.itemSlotClicked:Destroy()

		Fusion.doCleanup(scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
