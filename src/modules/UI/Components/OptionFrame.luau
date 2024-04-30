--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent, Tween, Computed = Fusion.OnEvent, Fusion.Tween, Fusion.Computed

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local sub = string.sub

local function OptionFrame(option: string, icon: string, self: table, index: number) : Frame
    local bgColor = Fusion.Value(fromRGB(30, 30, 30))
    local contentColor = Fusion.Value(fromRGB(255, 255, 255))

    if icon ~= "Chat" then option = sub(option, #icon + 2) end

    return Components.Frame({
        BackgroundTransparency = 0,
        Size = fromScale(0.9, 0.27),

        BackgroundColor3 = Tween(Computed(function(use)
            return use(bgColor)
        end), AssetBook.TweenInfos.threeHalf),

        [Fusion.Children] = {
            Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
            Components.UIStroke({
                Thickness = 2.8,
                Enabled = true,

                Color = Tween(Computed(function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            }),
            Components.HoverImageButton({
                [OnEvent("MouseEnter")] = function()
                    bgColor:set(fromRGB(255, 255, 255))
                    contentColor:set(fromRGB())
                end,
                [OnEvent("MouseLeave")] = function()
                    bgColor:set(fromRGB(30, 30, 30))
                    contentColor:set(fromRGB(255, 255, 255))
                end,
                [OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Next:Play()
                    self.chatChoices:set({})

                    Signals.NPCChat:Fire(index)
                end
            }),
            Components.ImageLabel({
                Name = "Icon",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.026, 0.5),
                Size = fromScale(0.072, 0.8),
                Image = AssetBook.ChatIcons[icon],

                ImageColor3 = Tween(Computed(function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            }),
            Components.CenterTextLabel({
                Name = "OptionText",
                Position = fromScale(0.528, 0.5),
                Size = fromScale(0.8, 0.7),
                Text = option,

                TextColor3 = Tween(Computed(function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            })
        }
    })
end

return OptionFrame
