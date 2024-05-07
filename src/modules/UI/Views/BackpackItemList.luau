--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local BackpackItemSlot = require(RepS.Modules.UI.Components.BackpackItemSlot)

local Computed, peek = Fusion.Computed, Fusion.peek

local tFind = table.find
local wait = task.wait
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset

local function BackpackItemList(self: table) : ScrollingFrame
    local scope = self.scope

    self.emptyList[#self.emptyList + 1] = HarukaLib:Hydrate(workspace.CurrentCamera, {
        ["Prop-ViewportSize"] = function(newSize: Vector2)
            self.absSize:set({
				newSize.X * 0.71,
				newSize.Y * 0.662,
			})
			self.absCellPadding:set({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
			self.absCellSize:set(peek(self.absSize)[1] / 15.58)
        end
    })

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

        [Fusion.OnEvent("ChildAdded")] = function()
            wait()
            self.noItemsShow:set(false)
        end,
        [Fusion.OnEvent("ChildRemoved")] = function()
            wait()
            if not peek(self.itemFrame) then return end --- in case ui destroy

            --- 1, stands for UIGridLayout
            self.noItemsShow:set(if #peek(self.itemFrame):GetChildren() == 1 then true else false)
        end,
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
            Fusion.ForValues(scope, self.items, function(use, localScope: table, item: IntValue)
                if use(self.chosenFilter) == "Others" then
                    local filter = { "Material", "Cosmetic", "Quest" }
                    if tFind(filter, ItemBook:FindItem(item.Name).Type) then return BackpackItemSlot(item, self, localScope) end

                else
                    if ItemBook:FindItem(item.Name).Type == use(self.chosenFilter) then return BackpackItemSlot(item, self, localScope) end
                end
            end),
        },
    })
end

return BackpackItemList
