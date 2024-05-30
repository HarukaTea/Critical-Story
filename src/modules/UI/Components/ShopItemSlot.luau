--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, OnEvent, Value, Computed, peek =
	Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Computed, Fusion.peek

local function ShopItemSlot(item: IntConstrainedValue, self: table, scope: table): ImageButton
	local isSelecting = Value(scope, false)

	--// Connections
	self.itemSlotClicked:Connect(function()
		isSelecting:set(false)
	end)

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
			})
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
			self.itemCost:set(itemInfo.Price)
			self.itemCostColor:set(if itemInfo.Price > self.plr:GetAttribute("Gold") then
				Color3.fromRGB(255, 0, 0) else Color3.fromRGB(255, 255, 0))
		end,
	})
end

return ShopItemSlot
