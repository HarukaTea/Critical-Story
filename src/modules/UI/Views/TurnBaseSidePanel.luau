--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)

local Children, Computed, Value, OnEvent, OnChange =
	Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.OnEvent, Fusion.OnChange

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
            [OnEvent("ChildAdded")] = _handleItems,
            [OnEvent("ChildRemoved")] = function()
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
        Position = fromScale(if id == "Items" then 0.332 else 0.668, -3.2),
        Size = fromScale(0.173, 3),
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

        [Children] = {
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
                local isSelecting = Value(false)

                local itemAmount
                if id == "Items" then
                    itemAmount = Value(self.inventory[item].Value)

                    Fusion.Hydrate(self.inventory[item])({
                        [OnChange("Value")] = function(newAmount: number)
                            itemAmount:set(newAmount)
                        end
                    })
                end

                return Components.Frame({
                    Name = item,
                    BackgroundTransparency = 0,
                    Size = fromScale(0.95, 0.224),

                    [Children] = {
                        Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 6.158 }),
                        Components.RoundUICorner(),
                        Components.UIStroke({
                            Thickness = 2.3,
                            Enabled = Computed(function(use)
                                return use(isSelecting)
                            end)
                        }),
                        Components.ImageLabel({
                            Name = "Icon",
                            Size = fromScale(1, 1),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            Image = "rbxassetid://"..ItemBook:FindItem(item).Icon,

                            [Children] = { Components.RoundUICorner() }
                        }),
                        Components.TextLabel({
                            Name = "Item",
                            AnchorPoint = v2New(0, 0.5),
                            Position = fromScale(0.2, 0.5),
                            Size = fromScale(0.712, 0.6),
                            RichText = if id == "Items" then true else false,
                            Text = Computed(function(use)
                                local itemInfo = ItemBook:FindItem(item)

                                if id == "Items" then
                                    return itemInfo.Name..[[  <font color="#f1c40f">x]]..use(itemAmount).."</font>"
                                else
                                    return itemInfo.Name
                                end
                            end),
                            TextXAlignment = Enum.TextXAlignment.Left
                        }),

                        Components.HoverImageButton({
                            [OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,
                            [OnEvent("MouseButton1Click")] = function()
                                if self.actionClickCD then return end

                                self.actionClickCD = true
                                self.panelPos:set(fromScale(0.5, 5))
                                self.transHPBarSize:set(fromScale(0, 0.875))

                                Events.NextActionRequest:Fire("Items", item)

                                wait(1)
                                self.actionClickCD = false
                            end
                        })
                    }
                })
            end, Fusion.cleanup),
            Components.Frame({
                Name = "Padding",
                Size = fromScale(0.95, 0.01)
            }),
        }
    })
end

return TurnBaseSidePanel
