--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Value, OnEvent, Computed = Fusion.Value, Fusion.OnEvent, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local wait = task.wait
local fromRGB, fromHex = Color3.fromRGB, Color3.fromHex

local function TurnBaseItemChoice(id: string, item: string, self: table, scope: table) : Frame
    local isSelecting = Value(scope, false)

    local itemAmount
    if id == "Items" then
        itemAmount = Value(scope, self.inventory[item].Value)

        scope[#scope + 1] = HarukaLib:Hydrate(self.inventory[item], {
            ["Prop-Value"] = function(newAmount: number)
                itemAmount:set(newAmount)
            end
        })
    end

    return Components.Frame(scope, {
        Name = item,
        BackgroundTransparency = 0,
        Size = fromScale(0.95, 0.224),

        [Fusion.Children] = {
            Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 6.158 }),
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 2.3,

                Enabled = Computed(scope, function(use)
                    return use(isSelecting)
                end)
            }),
            Components.ImageLabel(scope, {
                Name = "Icon",
                Size = fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = "rbxassetid://"..ItemBook:FindItem(item).Icon,

                [Fusion.Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Item",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.2, 0.5),
                Size = fromScale(0.55, 0.6),
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(scope, function()
                    return ItemBook:FindItem(item).Name
                end),
            }),
            Components.TextLabel(scope, {
                Name = if id == "Items" then "Amount" else "TP",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.76, 0.5),
                Size = fromScale(0.197, 0.6),
                TextXAlignment = Enum.TextXAlignment.Right,

                TextColor3 = Computed(scope, function(use)
                    return if id == "Items" then fromHex("#eccc68") else if use(self.charStatsDict.TP) < ItemBook:FindItem(item).TP then fromRGB(255, 0, 0) else fromRGB(0, 255, 255)
                end),
                Text = Computed(scope, function(use)
                    return if id == "Items" then "x"..use(itemAmount) else ItemBook:FindItem(item).TP.."%"
                end),
            }),

            Components.HoverImageButton(scope, {
                [OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [OnEvent("MouseButton1Click")] = function()
                    if self.actionClickCD then return end

                    if id == "Skills" then --// TP check
                        local TPNeeded = ItemBook:FindItem(item).TP :: number

                        if self.char:GetAttribute("TP") < TPNeeded then
                            Signals.CreateHint:Fire("You don't have enough TP!")
                            return
                        end
                    end

                    self.actionClickCD = true
                    self.panelPos:set(fromScale(0.5, 5))
                    self.transHPBarSize:set(fromScale(0, 0.875))
                    self.itemPanelVisible:set(false)
                    self.skillPanelVisible:set(false)

                    Events.NextActionRequest:Fire("Items", item)

                    wait(1)
                    self.actionClickCD = false
                end
            })
        }
    })
end

return TurnBaseItemChoice
