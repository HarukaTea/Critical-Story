--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OnEvent, Computed, Value =
    Fusion.OnEvent, Fusion.Computed, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local upper = string.upper
local fromRGB = Color3.fromRGB
local udNew = UDim.new
local wait = task.wait

local function TurnBaseAction(id: string, self: table) : Frame
    local IS_SELECTED = {
        Attack = Value(false),
        Defend = Value(false)
    }

    local function _hidePanel()
        self.panelPos:set(fromScale(0.5, 5))
        self.transHPBarSize:set(fromScale(0, 0.875))
    end
    return Components.Frame({
        Name = id,
        BackgroundColor3 = Computed(function(use)
            return if use(IS_SELECTED[id]) then fromRGB(255, 255, 255) else fromRGB()
        end),
        BackgroundTransparency = 0,

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.1, 0) }),
            Components.UIStroke({
                Enabled = true,

                Thickness = Fusion.Tween(Computed(function(use)
                    return if use(IS_SELECTED[id]) then 4 else 3
                end), AssetBook.TweenInfos.half),
                Color = Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end),
            }),
            Components.HoverImageButton({
                [OnEvent("MouseEnter")] = function()
                    IS_SELECTED[id]:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    IS_SELECTED[id]:set(false)
                end,
                [OnEvent("MouseButton1Click")] = function()
                    if self.plr:GetAttribute("NextAction") ~= "" then return end
                    if self.actionClickCD then return end

                    self.actionClickCD = true

                    _hidePanel()
                    Events.NextActionRequest:Fire(id)

                    wait(1)
                    self.actionClickCD = false
                end
            }),
            Components.ImageLabel({
                Name = "Icon",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.1),
                Size = fromScale(0.5, 0.5),

                Image = AssetBook.ActionPanelIcons[id],
                ImageColor3 = Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end),
            }),
            Components.TextLabel({
                Name = "Action",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(0.9, 0.3),
                Text = upper(id),
                TextColor3 = Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end),
            })
        }
    })
end

return TurnBaseAction
