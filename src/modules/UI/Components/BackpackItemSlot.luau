--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, OnEvent, Value, Computed, New, peek =
	Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Computed, Fusion.New, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local udNew = UDim.new

local function BackpackItemSlot(item: IntConstrainedValue, self: table, scope: Fusion.Scope): ImageButton
	local amount = Value(scope, item.Value)
	local equipped = Value(scope, item:GetAttribute("Equipped"))
	local pinned = Value(scope, item:GetAttribute("Pinned"))
	local isSelecting = Value(scope, false)

	--// Connections
	table.insert(scope, HarukaLib:Hydrate(item, {
		["Prop-Value"] = function(newAmount: number)
			amount:set(newAmount)
		end,
		["Attr-Equipped"] = function(state: boolean)
			equipped:set(state)

			self.filterInfo.Equip:set(if state then "UNEQUIP" else "EQUIP")
		end,
		["Attr-Pinned"] = function(state: boolean)
			pinned:set(state)

			self.filterInfo.Pin:set(if state then "UNPIN" else "PIN")
		end
	}))
	table.insert(scope, self.itemSlotClicked:Connect(function()
		isSelecting:set(false)
	end))

	item = item.Name

	local itemInfo = ItemBook:FindItem(item)
	if itemInfo.ItemId == nil then
		itemInfo = {
			["ItemId"] = "???",
			["Name"] = "???",
			["Type"] = "Material",
			["Tier"] = 1,
			["Desc"] = "???",
			["Stat"] = "???",
			["Icon"] = 2985521957,
			["IsSkill"] = false,
			["Mana"] = 0,
			["Price"] = 0
		}
	end

	return Components.HoverImageButton(scope, {
		Name = item,
		BackgroundTransparency = 0,
		Image = ClientUtil:CombineRbxId(itemInfo.Icon),

		[Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
					return if use(isSelecting) then 0.3 else 1
				end), AssetBook.TweenInfos.twiceHalf)
			}),
			Components.TextLabel(scope, {
				Name = "Equipped",
				AnchorPoint = v2New(0.5, 0.5),
				BackgroundColor3 = fromRGB(68, 135, 203),
				BackgroundTransparency = 0,
				Position = fromScale(0.9, 0.1),
				Size = fromScale(0.5, 0.5),
				ZIndex = 2,
				Text = "E",

				Visible = Computed(scope, function(use: Fusion.Use)
					return use(equipped)
				end),

				[Children] = {
					Components.RoundUICorner(scope),
					New(scope, "UIPadding")({
						PaddingTop = udNew(0, 2),
						PaddingBottom = udNew(0, 2)
					})
				},
			}),
			Components.TextLabel(scope, {
				Name = "Pinned",
				AnchorPoint = v2New(0.5, 0.5),
				BackgroundColor3 = fromRGB(124, 63, 189),
				BackgroundTransparency = 0,
				Position = fromScale(0.9, 0.1),
				Size = fromScale(0.5, 0.5),
				ZIndex = 3,
				Text = "P",

				Visible = Computed(scope, function(use: Fusion.Use)
					if not use(equipped) then return use(pinned) end
				end),

				[Children] = {
					Components.RoundUICorner(scope),
					New(scope, "UIPadding")({
						PaddingTop = udNew(0, 2),
						PaddingBottom = udNew(0, 2)
					})
				},
			}),
			Components.TextLabel(scope, {
				Name = "Amount",
				Position = fromScale(0.2, 0.65),
				Size = fromScale(1, 0.35),
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(scope, function(use: Fusion.Use)
					local itemAmount = use(amount) :: number

					return if itemAmount <= 1 then "" else "x"..itemAmount
				end),
			}),
		},
		[OnEvent("MouseEnter")] = function()
			isSelecting:set(true)
		end,
		[OnEvent("MouseLeave")] = function()
			isSelecting:set(if peek(self.itemFrame)[item]:GetAttribute("Selected")
				then true
				else false)
		end,
		[OnEvent("MouseButton1Click")] = function()
			local itemFrame = peek(self.itemFrame) :: Frame

			self:DeselectAll()
			if itemFrame[item]:GetAttribute("Selected") then return end

			self.itemSlotClicked:Fire()

			itemFrame[item]:SetAttribute("Selected", true)
			isSelecting:set(true)

			self.itemName:set(itemInfo.Name)
			self.itemTierColor:set(AssetBook.TierColor[peek(itemInfo.Tier)])
			self.itemStats:set(HarukaLib:RichTextify(itemInfo.Stat))
			self.itemDesc:set(itemInfo.Desc)

			local filterInfo = self.filterInfo :: table

			filterInfo.Equip:set(if peek(equipped) then "UNEQUIP" else "EQUIP")
			filterInfo.Pin:set(if peek(pinned) then "UNPIN" else "PIN")
		end,
	})
end

return BackpackItemSlot
