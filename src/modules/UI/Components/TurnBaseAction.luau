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
    local isSelecting = Value(false)

    return Components.Frame({
        Name = id,
        BackgroundColor3 = Computed(function(use)
            return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
        end),
        BackgroundTransparency = 0,

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.1, 0) }),
            Components.UIStroke({
                Enabled = true,

                Thickness = Computed(function(use)
                    return if use(isSelecting) then 4 else 3
                end),
                Color = Computed(function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),
            }),
            Components.HoverImageButton({
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

                    elseif id == "Skills" then
                        self.skillPanelVisible:set(not Fusion.peek(self.skillPanelVisible))

                    else
                        self.actionClickCD = true
                        self.panelPos:set(fromScale(0.5, 5))
                        self.transHPBarSize:set(fromScale(0, 0.875))

                        Events.NextActionRequest:Fire(id)

                        wait(1)
                        self.actionClickCD = false
                    end
                end
            }),
            Components.ImageLabel({
                Name = "Icon",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.1),
                Size = fromScale(0.5, 0.5),
                Image = AssetBook.ActionPanelIcons[id],

                ImageColor3 = Computed(function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),
            }),
            Components.TextLabel({
                Name = "Action",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(0.9, 0.3),
                Text = upper(id),

                TextColor3 = Computed(function(use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),
            })
        }
    })
end

return TurnBaseAction
