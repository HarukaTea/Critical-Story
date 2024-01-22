--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local BackpackItemSlot = require(RepS.Modules.UI.Components.BackpackItemSlot)
local BGTitle = require(RepS.Modules.UI.Components.BGTitle)
local BottomBtns = require(RepS.Modules.UI.Components.BottomBtns)
local FilterButton = require(RepS.Modules.UI.Components.FilterButton)

local ItemDescFrame = require(RepS.Modules.UI.Views.ItemDescFrame)

local Children, Computed, Value, OnChange, OnEvent, peek =
	Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.OnChange, Fusion.OnEvent, Fusion.peek

local Backpack = {}
Backpack.__index = Backpack

local tFind = table.find
local wait = task.wait
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local fromRGB = Color3.fromRGB
local sFind = string.find

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
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame.Frame

	for _, element in classFrame:GetChildren() do
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
	local classFrame = self.plrGui.AdventurerStats.BG.ClassFrame.Frame

	local check, sameSlot = false, nil
	for _, element in classFrame:GetChildren() do
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

	self.inventory = plr:WaitForChild("Inventory", 999)

	self.absSize = Value({ workspace.CurrentCamera.ViewportSize.X * 0.71, workspace.CurrentCamera.ViewportSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize, self.absTextSize = Value(peek(self.absSize)[1] / 15.58), Value(peek(self.absSize)[2] * 0.345 / 4.66)
	self.absScrollSize, self.absContentSize = Value(90), Value(30)

	self.UI, self.itemFrame, self.itemDescFrame = Value(), Value(), Value()
	self.btnsFrame = { Left = Value(), Right = Value() }

	self.items, self.chosenFilter, self.noItemsShow = Value({}), Value("All"), Value(false)

	Components.ScreenGui({
		Name = "Backpack",
		Parent = self.plrGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
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
							Components.ScrollingFrame({
								Name = "Items",
								Size = fromScale(0.99, 0.93),
								ScrollBarThickness = 6,
								ScrollingDirection = Enum.ScrollingDirection.Y,
								CanvasSize = Computed(function(use)
									if use(self.absContentSize) > use(self.absScrollSize) then
										return fromOffset(0, use(self.absContentSize))
									else
										return fromOffset(0, 0)
									end
								end),
								ScrollingEnabled = Computed(function(use)
									return if use(self.absContentSize) > use(self.absScrollSize) then true else false
								end),

								[Fusion.Ref] = self.itemFrame,
								[OnEvent("ChildAdded")] = function()
									wait()
									self.noItemsShow:set(false)
								end,
								[OnEvent("ChildRemoved")] = function()
									wait()
									if #peek(self.itemFrame):GetChildren() == 1 then
										self.noItemsShow:set(true)
									else
										self.noItemsShow:set(false)
									end
								end,
								[Fusion.OnChange("AbsoluteSize")] = function(newSize)
									self.absScrollSize:set(newSize.Y)
								end,

								[Children] = {
									Fusion.New("UIGridLayout")({
										CellPadding = Computed(function(use)
											return fromOffset(use(self.absCellPadding)[1], use(self.absCellPadding)[2])
										end),
										CellSize = Computed(function(use)
											return fromOffset(use(self.absCellSize), use(self.absCellSize))
										end),

										[Fusion.OnChange("AbsoluteContentSize")] = function(newSize)
											self.absContentSize:set(newSize.Y)
										end,
									}),
									Fusion.ForValues(self.items, function(use, item)
										if use(self.chosenFilter) == "All" then
											return BackpackItemSlot(item.Name, self)

										elseif use(self.chosenFilter) == "Others" then
											local filter = { "Material", "Cosmetic", "Companion" }
											if tFind(filter, AssetBook.Items.ItemType[item.Name]) then
												return BackpackItemSlot(item.Name, self)
											end
										else
											if AssetBook.Items.ItemType[item.Name] == use(self.chosenFilter) then
												return BackpackItemSlot(item.Name, self)
											end
										end
									end, Fusion.cleanup),
								},
							}),
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
								FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Bold),
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

	--- action bindings
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
		self.plrGui.AdventurerMenu.BG:SetAttribute("CurrentEx", curUI)

		_setExVisibleState(ui, if curUI == "None" then false else true)
		_setOthersVisibleState(if curUI == "None" then true else false)
	end
	local function _openBackpack(actionName: nil, inputState: Enum.UserInputState)
		if inputState ~= Enum.UserInputState.Begin then
			return
		end

		local backpackFrame, menuFrame = peek(self.UI), self.plrGui.AdventurerMenu

		if menuFrame.BG:GetAttribute("CurrentEx") == "None" then
			_setVisible("Backpack", backpackFrame)
		elseif menuFrame.BG:GetAttribute("CurrentEx") == "Backpack" then
			_setVisible("None", backpackFrame)
		elseif menuFrame.BG:GetAttribute("CurrentEx") == "Menu" then
			menuFrame.BG:SetAttribute("CurrentEx", "Backpack")

			_setExVisibleState(backpackFrame, true)
			_setExVisibleState(menuFrame, false)
		end
	end
	CAS:BindAction("OpenBackpack", _openBackpack, false, Enum.KeyCode.C)

	-- setup
	self.items:set(self.inventory:GetChildren())

	--- listening events
	Fusion.Hydrate(workspace.CurrentCamera)({
		[OnChange("ViewportSize")] = function(newSize)
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
end
