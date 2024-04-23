--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local BackpackItemSlot = require(RepS.Modules.UI.Components.BackpackItemSlot)

local Computed, Value, peek = Fusion.Computed, Fusion.Value, Fusion.peek

local Backpack = {}
Backpack.__index = Backpack

local tFind = table.find
local wait = task.wait
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset

local function BackpackItemList(self: table) : ScrollingFrame
    local camVPSize = workspace.CurrentCamera.ViewportSize

    self.absSize = Value({ camVPSize.X * 0.71, camVPSize.Y * 0.662 })
	self.absCellPadding = Value({ peek(self.absSize)[1] * 0.02, peek(self.absSize)[2] * 0.02 })
	self.absCellSize, self.absTextSize = Value(peek(self.absSize)[1] / 15.58), Value(peek(self.absSize)[2] * 0.345 / 4.66)
	self.absScrollSize, self.absContentSize = Value(90), Value(30)

    return Components.ScrollingFrame({
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

        [Fusion.OnEvent("ChildAdded")] = function()
            wait()
            self.noItemsShow:set(false)
        end,
        [Fusion.OnEvent("ChildRemoved")] = function()
            wait()
            if not peek(self.itemFrame) then return end --- in case ui destroy

            if #peek(self.itemFrame):GetChildren() == 1 then
                self.noItemsShow:set(true)
            else
                self.noItemsShow:set(false)
            end
        end,
        [Fusion.OnChange("AbsoluteSize")] = function(newSize)
            self.absScrollSize:set(newSize.Y)
        end,

        [Fusion.Children] = {
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
            Fusion.ForValues(self.items, function(use, item: IntValue)
                if use(self.chosenFilter) == "All" then
                    return BackpackItemSlot(item, self)

                elseif use(self.chosenFilter) == "Others" then
                    local filter = { "Material", "Cosmetic", "Companion" }
                    if tFind(filter, AssetBook.Items.ItemType[item.Name]) then
                        return BackpackItemSlot(item, self)
                    end
                else
                    if AssetBook.Items.ItemType[item.Name] == use(self.chosenFilter) then
                        return BackpackItemSlot(item, self)
                    end
                end
            end, Fusion.cleanup),
        },
    })
end

return BackpackItemList
