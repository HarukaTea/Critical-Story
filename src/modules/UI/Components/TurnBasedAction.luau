--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OnEvent, Computed, Tween, Value =
    Fusion.OnEvent, Fusion.Computed, Fusion.Tween, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local upper = string.upper
local fromRGB = Color3.fromRGB
local udNew = UDim.new

local function TurnBasedAction(id: string, self: table) : Frame
    local IS_SELECTED = {
        Attack = Value(false),
        Items = Value(false),
        Skills = Value(false),
        Defend = Value(false)
    }
    local ICONS = {
        Attack = "rbxassetid://2034122114",
        Items = "rbxassetid://2228031606",
        Skills = "rbxassetid://2034172262",
        Defend = "rbxassetid://4601012009"
    }

    return Components.Frame({
        Name = id,
        BackgroundColor3 = Tween(Computed(function(use)
            return if use(IS_SELECTED[id]) then fromRGB(255, 255, 255) else fromRGB()
        end), AssetBook.TweenInfos.half),
        BackgroundTransparency = 0,

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.1, 0) }),
            Components.UIStroke({
                Enabled = true,

                Thickness = Tween(Computed(function(use)
                    return if use(IS_SELECTED[id]) then 4 else 3
                end), AssetBook.TweenInfos.half),
                Color = Tween(Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end), AssetBook.TweenInfos.half),
            }),
            Components.HoverImageButton({
                [OnEvent("MouseEnter")] = function()
                    IS_SELECTED[id]:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    IS_SELECTED[id]:set(false)
                end,
                [OnEvent("MouseButton1Click")] = function()
                    --[[
                        TODO: Action
                    ]]
                end
            }),
            Components.ImageLabel({
                Name = "Icon",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.1),
                Size = fromScale(0.5, 0.5),

                Image = ICONS[id],
                ImageColor3 = Tween(Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end), AssetBook.TweenInfos.half),
            }),
            Components.TextLabel({
                Name = "Action",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(0.9, 0.3),
                Text = upper(id),
                TextColor3 = Tween(Computed(function(use)
                    return if use(IS_SELECTED[id]) then fromRGB() else fromRGB(255, 255, 255)
                end), AssetBook.TweenInfos.half),
            })
        }
    })
end

return TurnBasedAction
