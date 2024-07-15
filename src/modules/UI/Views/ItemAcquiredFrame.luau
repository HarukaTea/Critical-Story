--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)

local ItemBar = require(RepS.Modules.UI.Components.ItemBar)

local Children, New = Fusion.Children, Fusion.New

local udNew = UDim.new
local insert, tFind, remove = table.insert, table.find, table.remove
local wait = task.wait

local function ItemAcquiredFrame(self: table): Frame
	local scope = self.scope :: Fusion.Scope

	local function _giveDrop(item: string)
		local nowAdded = Fusion.peek(self.newAddedItems)

		insert(nowAdded, item)
		self.newAddedItems:set(nowAdded)

		Spawn(function()
			wait(6)
			local afterAdded = Fusion.peek(self.newAddedItems)

			remove(afterAdded, tFind(afterAdded, item))
			self.newAddedItems:set(afterAdded)
		end)
	end
	Events.GiveDrop:Connect(_giveDrop)

	return Components.Frame(scope, {
		Name = "ItemAcquiredFrame",
		Position = UDim2.fromScale(0.5, -1.8),

		[Children] = {
			New(scope, "UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = udNew(0.15, 0),
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
			Fusion.ForValues(scope, self.newAddedItems, function(_, localScope: Fusion.Scope, item: string)
				return ItemBar(item, localScope)
			end),
		},
	})
end

return ItemAcquiredFrame
