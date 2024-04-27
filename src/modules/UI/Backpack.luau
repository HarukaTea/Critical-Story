--!nocheck
--!optimize 2
--!native

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ClientUtil =require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local BackpackItemList = require(RepS.Modules.UI.Views.BackpackItemList)

local BGTitle = require(RepS.Modules.UI.Components.BGTitle)
local BottomBtns = require(RepS.Modules.UI.Components.BottomBtns)
local FilterButton = require(RepS.Modules.UI.Components.FilterButtonBackpack)

local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)

local Children, Computed, Value, OnChange, OnEvent, peek =
	Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.OnChange, Fusion.OnEvent, Fusion.peek

local Backpack = {}
Backpack.__index = Backpack

local wait = task.wait
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind = string.find
local fontFromName = Font.fromName

--[[
	Deselect all items, and hide the item description
]]
function Backpack:DeselectAll()
	for _, element in peek(self.itemFrame):GetChildren() do
		element:SetAttribute("Selected", nil)
		if element:IsA("ImageButton") then
			element.UIStroke.Enabled = false
		end
	end

	local itemDescFrame = peek(self.itemDescFrame)
	itemDescFrame.HorizonLine.Visible = false
	itemDescFrame.ItemName.Text = ""
	itemDescFrame.ItemType.Text = ""
	itemDescFrame.ItemTier.Text = ""
	itemDescFrame.ItemStats.Text = ""
	itemDescFrame.ItemDesc.Text = ""

	peek(self.btnsFrame.Right).Equip.Visible = false
	peek(self.btnsFrame.Right).Pin.Visible = false
end

--[[
	Check if the slot is equipped, and return free slot if has
]]
function Backpack:CheckSlot(type: string) : string
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

	for _, element in classFrame:GetDescendants() do
		if sFind(element.Name, type) then
			if not element:GetAttribute("Equipped") then
				return element.Name
			end
		end
	end

	return "Full"
end

--[[
	Check if it's already equipped, more like a sanity check
]]
function Backpack:CheckSameItem(item: string, type: string) : (string, string?)
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame

	local check, sameSlot = false, nil
	for _, element in classFrame:GetDescendants() do
		if sFind(element.Name, type) and element:GetAttribute("ItemEquipped") == item then
			check = true
			sameSlot = element.Name
		end
	end
	if not check then
		return "None"
	else
		return "Exist", sameSlot
	end
end

return function(plr: Player)
	local self = setmetatable({}, Backpack)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()
	local char = self.char

	self.inventory = plr:WaitForChild("Inventory", 999)

	self.UI, self.itemFrame, self.itemDescFrame = Value(), Value(), Value()
	self.items, self.noItemsShow = Value(self.inventory:GetChildren()), Value(true)
	self.chosenFilter = Value("All")

	Components.ScreenGui({
		Name = "Backpack",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,
		[Fusion.Ref] = self.UI,

		[Children] = {
			Components.Frame({
				Name = "BG",
				Visible = false,
				ZIndex = 2,

				[Children] = {
					BGTitle("Backpack", self),
					BottomBtns("Left", {
						FilterButton("Passive", self),
						FilterButton("Active", self),
						FilterButton("Others", self),
					}, self),
					BottomBtns("Right", {
						FilterButton("Equip", self),
						FilterButton("Pin", self),
					}, self),

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

						Visible = Computed(function(use)
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
	Fusion.Hydrate(workspace.CurrentCamera)({
		[OnChange("ViewportSize")] = function(newSize: Vector2)
			self.absSize:set({
				newSize.X * 0.71,
				newSize.Y * 0.662,
			})
			self.absCellPadding:set({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
			self.absCellSize:set(peek(self.absSize)[1] / 15.58)
			self.absTextSize:set(peek(self.absSize)[2] * 0.345 / 4.66)
		end,
	})
	Fusion.Hydrate(self.inventory)({
		[OnEvent("ChildAdded")] = function()
			wait()
			self.items:set(self.inventory:GetChildren())
		end,
		[OnEvent("ChildRemoved")] = function()
			if not plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

			wait()
			self.items:set(self.inventory:GetChildren())
		end,
	})

	--// Clear
	local function _clearGarbage()
		CAS:UnbindAction("OpenBackpack")

		peek(self.UI):Destroy()
		plr:SetAttribute("CurrentMenu", "None")
	end
	char.Humanoid.Died:Once(_clearGarbage)
end
