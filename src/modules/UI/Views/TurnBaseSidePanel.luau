--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local TurnBaseItemChoice = require(RepS.Modules.UI.Components.TurnBaseItemChoice)

local Computed = Fusion.Computed

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local wait = task.wait

local function TurnBaseSidePanel(id: string, self: table) : ScrollingFrame
    if id == "Items" then
        local function _handleItems()
            wait()
            local items = self.inventory:GetChildren()
            local realItems, realSkills = {}, {}

            for _, item: IntValue in items do
                local itemInfo = ItemBook:FindItem(item.Name)

                if itemInfo.Type == "Active" and item.Value > 0 then
                    if itemInfo.IsCM then
                        realItems[#realItems + 1] = item.Name

                    elseif itemInfo.IsSkill then
                        realSkills[#realSkills + 1] = item.Name
                    end
                end
            end

            self.items:set(realItems)
            self.skills:set(realSkills)
        end

        _handleItems()
        Fusion.Hydrate(self.inventory)({
            [Fusion.OnEvent("ChildAdded")] = _handleItems,
            [Fusion.OnEvent("ChildRemoved")] = function()
                if not self.plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

                _handleItems()
            end,
        })
    end

    local index = if id == "Items" then 1 else 2
    return Components.ScrollingFrame({
        Name = id.."SidePanel",
        ClipsDescendants = true,
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(if id == "Items" then 0.332 else 0.668, -8),
        Size = fromScale(0.173, 8),
        ScrollingDirection = Enum.ScrollingDirection.Y,

        Visible = Computed(function(use)
            return if id == "Items" then use(self.itemPanelVisible) else use(self.skillPanelVisible)
        end),
        CanvasSize = Computed(function(use)
            return if use(self.sidePanelAbsContentSize[index]) > use(self.sidePanelAbsSize[index]) then fromOffset(0, use(self.sidePanelAbsContentSize[index])) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(function(use)
            return if use(self.sidePanelAbsContentSize[index]) > use(self.sidePanelAbsSize[index]) then true else false
        end),

        [Fusion.OnChange("AbsoluteSize")] = function(newSize: Vector2)
            self.sidePanelAbsSize[index]:set(newSize.Y)
        end,

        [Fusion.Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,

                [Fusion.OnChange("AbsoluteContentSize")] = function(newSize: Vector2)
                    self.sidePanelAbsContentSize[index]:set(newSize.Y)
                end
            }),
            Components.Frame({
                Name = "Padding",
                Size = fromScale(0.95, 0.01)
            }),

            Fusion.ForValues(if id == "Items" then self.items else self.skills, function(_, item: string)
                return TurnBaseItemChoice(id, item, self)
            end, Fusion.cleanup),

            Components.Frame({
                Name = "Padding",
                Size = fromScale(0.95, 0.01)
            }),
        }
    })
end

return TurnBaseSidePanel
