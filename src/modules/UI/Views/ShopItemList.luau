--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ShopItemSlot = require(RepS.Modules.UI.Components.ShopItemSlot)

local Computed, peek = Fusion.Computed, Fusion.peek

local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset

local function ShopItemList(id: string, self: table) : ScrollingFrame
    local scope = self.scope :: Fusion.Scope

    table.insert(scope, HarukaLib:Hydrate(workspace.CurrentCamera, {
        ["Prop-ViewportSize"] = function(newSize: Vector2)
            self.absSize:set({
				newSize.X * 0.71,
				newSize.Y * 0.662,
			})
			self.absCellPadding:set({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
			self.absCellSize:set(peek(self.absSize)[1] / 15.58)
        end
    }))

    table.insert(scope,Events.EnterShopping.On(function(data)
        local items = data.Items

        self.items:set(items)
        self:DeselectAll()

        ClientUtil:OpenUIEx(self.plr, "Shop")
    end))

    self.itemFrame = Components.ScrollingFrame(scope, {
        Name = "Items",
        Size = fromScale(0.99, 0.93),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = false,

        CanvasSize = Computed(scope, function(use: Fusion.Use)
            return if use(self.absContentSize).Y > use(self.absScrollSize).Y then fromOffset(0, use(self.absContentSize).Y) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(scope, function(use: Fusion.Use)
            return if use(self.absContentSize).Y > use(self.absScrollSize).Y then true else false
        end),

        [Fusion.Out("AbsoluteSize")] = self.absScrollSize,

        [Fusion.Children] = {
            Fusion.New(scope, "UIGridLayout")({
                CellPadding = Computed(scope, function(use: Fusion.Use)
                    return fromOffset(use(self.absCellPadding)[1], use(self.absCellPadding)[2])
                end),
                CellSize = Computed(scope, function(use: Fusion.Use)
                    return fromOffset(use(self.absCellSize), use(self.absCellSize))
                end),

                [Fusion.Out("AbsoluteContentSize")] = self.absContentSize,
            }),
            Fusion.ForValues(scope, self.items, function(_, localScope: Fusion.Scope, item: string)
                return ShopItemSlot(item, self, localScope)
            end),
        },
    })

    return self.itemFrame
end

return ShopItemList
