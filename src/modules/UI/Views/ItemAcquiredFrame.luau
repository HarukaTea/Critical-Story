--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)

local ItemBar = require(RepS.Modules.UI.Components.ItemBar)

local Children, New, Value = Fusion.Children, Fusion.New, Fusion.Value

local udNew = UDim.new
local fromScale = UDim2.fromScale
local insert, tFind, remove = table.insert, table.find, table.remove
local wait = task.wait

local function ItemAcquiredFrame(self: table): Frame
	self.newAddedItems = Value({})

	local function _giveDrop(item: string)
		local nowAdded = Fusion.peek(self.newAddedItems)

		insert(nowAdded, item)
		self.newAddedItems:set(nowAdded)

		Spawn(function()
			wait(4)
			local afterAdded = Fusion.peek(self.newAddedItems)

			remove(afterAdded, tFind(afterAdded, item))
			self.newAddedItems:set(afterAdded)
		end)
	end
	Events.GiveDrop:Connect(_giveDrop)

	return Components.Frame({
		Name = "ItemAcquiredFrame",

		[Children] = {
			New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = udNew(0.15, 0),
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
			Fusion.ForValues(self.newAddedItems, function(use, item: string)
				local info = {
					Icon = AssetBook.Items.ItemImages[item],
					Name = AssetBook.Items.ItemName[item],
					TierColor = AssetBook.TierColor[AssetBook.Items.ItemTier[item]],
					Position = Value(fromScale(1.2, 0))
				}

				return ItemBar(info)
			end, Fusion.cleanup),
		},
	})
end

return ItemAcquiredFrame
