--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, OnEvent, Value, Computed, New, peek =
	Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Computed, Fusion.New, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local tFind = table.find
local udNew = UDim.new

local function BackpackItemSlot(item: IntConstrainedValue, self: table, scope: table): ImageButton
	local amount = Value(scope, item.Value)
	local equipped = Value(scope, item:GetAttribute("Equipped"))
	local pinned = Value(scope, item:GetAttribute("Pinned"))
	local isSelecting = Value(scope, false)

	--// Connections
	scope[#scope + 1] = HarukaLib:Hydrate(item, {
		["Prop-Value"] = function(newAmount: number)
			amount:set(newAmount)
		end,
		["Attr-Equipped"] = function(state: boolean)
			equipped:set(state)

			self.filterInfo.Equip.Text:set(if state then "UNEQUIP" else "EQUIP")
		end,
		["Attr-Pinned"] = function(state: boolean)
			pinned:set(state)

			self.filterInfo.Pin.Text:set(if state then "UNPIN" else "PIN")
		end
	})
	self.itemSlotClicked:Connect(function()
		isSelecting:set(false)
	end)

	item = item.Name
	local itemInfo = ItemBook:FindItem(item)
	return Components.HoverImageButton(scope, {
		Name = item,
		BackgroundTransparency = 0,
		Image = "rbxassetid://"..itemInfo.Icon,

		[Children] = {
			Components.RoundUICorner(scope),
			Components.UIStroke(scope, {
				Thickness = 3,
				Enabled = true,

				Transparency = Fusion.Tween(scope, Computed(scope, function(use)
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

				Visible = Computed(scope, function(use)
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

				Visible = Computed(scope, function(use)
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

				Text = Computed(scope, function(use)
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

			local itemType = itemInfo.Type
			self.horizonLineVisible:set(true)
			self.itemName:set(itemInfo.Name)
			self.itemType:set(itemType)
			self.itemTypeColor:set(AssetBook.TypeColor[itemType])
			self.itemTier:set(itemInfo.Tier)
			self.itemTierColor:set(AssetBook.TierColor[peek(self.itemTier)])
			self.itemStats:set(HarukaLib:RichTextify(itemInfo.Stat))
			self.itemDesc:set(itemInfo.Desc)

			local filterInfo = self.filterInfo :: table
			local blacklist = { "Material" }

			filterInfo.Equip.Visible:set(if not tFind(blacklist, itemType) then true else false)
			filterInfo.Equip.Text:set(if peek(equipped) then "UNEQUIP" else "EQUIP")

			filterInfo.Use.Visible:set(false)
			if itemType == "Active" and not itemInfo.IsSkill then filterInfo.Use.Visible:set(true) end

			filterInfo.Pin.Visible:set(true)
			filterInfo.Pin.Text:set(if peek(pinned) then "UNPIN" else "PIN")
			filterInfo.Pin.Size:set(if peek(filterInfo.Equip.Visible) then fromScale(0.116, 1) else fromScale(0.237, 1))
		end,
	})
end

return BackpackItemSlot
