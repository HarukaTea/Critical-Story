--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OnEvent, Computed, Value = Fusion.OnEvent, Fusion.Computed, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local upper = string.upper
local fromRGB = Color3.fromRGB
local udNew = UDim.new
local wait = task.wait

local function TurnBaseAction(id: string, self: table) : Frame
    local scope = self.scope
    local isSelecting = Value(scope, false)

    return Components.Frame(scope, {
        Name = id,
        BackgroundTransparency = 0,

        BackgroundColor3 = Computed(scope, function(use)
            return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
        end),

        [Fusion.Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.1, 0) }),
            Components.UIStroke(scope, {
                Enabled = true,
                Thickness = 3.5,

                Color = Computed(scope, function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
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
                    if self.plr:GetAttribute("NextAction") ~= "" then return end
                    if self.actionClickCD then return end

                    if id == "Items" then
                        self.itemPanelVisible:set(not Fusion.peek(self.itemPanelVisible))
                        self.skillPanelVisible:set(false)

                    elseif id == "Skills" then
                        self.skillPanelVisible:set(not Fusion.peek(self.skillPanelVisible))
                        self.itemPanelVisible:set(false)

                    else
                        self.actionClickCD = true

                        self.panelPos:set(fromScale(0.5, 5))
                        self.skillPanelVisible:set(false)
                        self.itemPanelVisible:set(false)

                        Events.NextActionRequest:Fire(id)

                        wait(1)
                        self.actionClickCD = false
                    end
                end
            }),
            Components.ImageLabel(scope, {
                Name = "Icon",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.1),
                Size = fromScale(0.5, 0.5),
                Image = AssetBook.ActionPanelIcons[id],

                ImageColor3 = Computed(scope, function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),
            }),
            Components.TextLabel(scope, {
                Name = "Action",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(0.9, 0.3),
                Text = upper(id),

                TextColor3 = Computed(scope, function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),
            })
        }
    })
end

return TurnBaseAction
