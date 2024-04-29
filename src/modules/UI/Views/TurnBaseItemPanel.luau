--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed, Value, OnEvent, OnChange =
	Fusion.Children, Fusion.Computed, Fusion.Value, Fusion.OnEvent, Fusion.OnChange

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local wait = task.wait

local function TurnBaseItemPanel(self: table) : ScrollingFrame
    self.inventory = self.plr:WaitForChild("Inventory", 999)
    self.itemPanelAbsContentSize, self.itemPanelAbsSize = Value(0), Value(0)
    self.items = Value({})

    local function _handleItems()
        wait()
        local items = self.inventory:GetChildren()
        local realItems = {}

        for _, item: IntValue in items do
            if not AssetBook.Items.IsSkill[item.Name]
                and AssetBook.Items.ItemType[item.Name] == "Active"
                and item.Value > 0 then

                realItems[#realItems + 1] = item.Name
            end
        end

        self.items:set(realItems)
    end
    _handleItems()
    Fusion.Hydrate(self.inventory)({
		[OnEvent("ChildAdded")] = _handleItems,
		[OnEvent("ChildRemoved")] = function()
			if not self.plr:IsDescendantOf(Players) then return end --- cuz plr left also triggers ChildRemoved

			_handleItems()
		end,
	})


    return Components.ScrollingFrame({
        Name = "ItemPanel",
        ClipsDescendants = true,
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.332, -3.2),
        Size = fromScale(0.173, 3),
        ScrollingDirection = Enum.ScrollingDirection.Y,

        CanvasSize = Computed(function(use)
            return if use(self.itemPanelAbsContentSize) > use(self.itemPanelAbsSize) then fromOffset(0, use(self.itemPanelAbsContentSize) + 20) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(function(use)
            return if use(self.itemPanelAbsContentSize) > use(self.itemPanelAbsSize) then true else false
        end),

        [Fusion.OnChange("AbsoluteSize")] = function(newSize: Vector2)
            self.itemPanelAbsSize:set(newSize.Y)
        end,

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,

                [Fusion.OnChange("AbsoluteContentSize")] = function(newSize: Vector2)
                    self.itemPanelAbsContentSize:set(newSize.Y)
                end
            }),
            Components.Frame({
                Name = "PaddingTop",
                Size = fromScale(0.95, 0.01)
            }),
            Fusion.ForValues(self.items, function(_, item: string)
                local isSelecting = Value(false)
                local itemAmount = Value(self.inventory[item].Value)

                Fusion.Hydrate(self.inventory[item])({
                    [OnChange("Value")] = function(newAmount: number)
                        itemAmount:set(newAmount)
                    end
                })

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
                            Image = AssetBook.Items.ItemImages[item],

                            [Children] = { Components.RoundUICorner() }
                        }),
                        Components.TextLabel({
                            Name = "Item",
                            AnchorPoint = v2New(0, 0.5),
                            Position = fromScale(0.228, 0.5),
                            Size = fromScale(0.712, 0.6),
                            RichText = true,
                            Text = Computed(function(use)
                                return AssetBook.Items.ItemName[item]..[[  <font color="#f1c40f">x]]..use(itemAmount).."</font>"
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
                Name = "PaddingBottom",
                Size = fromScale(0.95, 0.01)
            }),
        }
    })
end

return TurnBaseItemPanel
