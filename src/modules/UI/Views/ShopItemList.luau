--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ShopItemSlot = require(RepS.Modules.UI.Components.ShopItemSlot)

local Computed, peek = Fusion.Computed, Fusion.peek

local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset

local function ShopItemList(id: string, self: table) : ScrollingFrame
    local scope = self.scope

    self.Add(HarukaLib:Hydrate(workspace.CurrentCamera, {
        ["Prop-ViewportSize"] = function(newSize: Vector2)
            self.absSize:set({
				newSize.X * 0.71,
				newSize.Y * 0.662,
			})
			self.absCellPadding:set({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
			self.absCellSize:set(peek(self.absSize)[1] / 15.58)
        end
    }))

    local function _handleItems(passedId: string, items: table, shopName: string)
        if passedId == id then
            self.items:set(items)
            self.visible:set(true)
            self.currentShop:set(shopName)
        end
    end
    Events.EnterShopping:Connect(_handleItems)

    return Components.ScrollingFrame(scope, {
        Name = "Items",
        Size = fromScale(0.99, 0.93),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = false,

        CanvasSize = Computed(scope, function(use)
            return if use(self.absContentSize) > use(self.absScrollSize) then fromOffset(0, use(self.absContentSize)) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(scope, function(use)
            return if use(self.absContentSize) > use(self.absScrollSize) then true else false
        end),
        [Fusion.Ref] = self.itemFrame,

        [Fusion.OnChange("AbsoluteSize")] = function(newSize)
            self.absScrollSize:set(newSize.Y)
        end,

        [Fusion.Children] = {
            Fusion.New(scope, "UIGridLayout")({
                CellPadding = Computed(scope, function(use)
                    return fromOffset(use(self.absCellPadding)[1], use(self.absCellPadding)[2])
                end),
                CellSize = Computed(scope, function(use)
                    return fromOffset(use(self.absCellSize), use(self.absCellSize))
                end),

                [Fusion.OnChange("AbsoluteContentSize")] = function(newSize)
                    self.absContentSize:set(newSize.Y)
                end,
            }),
            Fusion.ForValues(scope, self.items, function(_, localScope: table, item: string)
                return ShopItemSlot(item, self, localScope)
            end),
        },
    })
end

return ShopItemList
