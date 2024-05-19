--!nocheck

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

local function ChatOption(option: string, icon: string, self: table, index: number, scope: table) : Frame
    local bgColor = Fusion.Value(scope, fromRGB(30, 30, 30))
    local contentColor = Fusion.Value(scope, fromRGB(255, 255, 255))

    if icon ~= "Chat" then option = sub(option, #icon + 2) end

    return Components.Frame(scope, {
        BackgroundTransparency = 0,
        Size = fromScale(0.9, 0.27),

        BackgroundColor3 = Tween(scope, Computed(scope, function(use)
            return use(bgColor)
        end), AssetBook.TweenInfos.threeHalf),

        [Fusion.Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
            Components.UIStroke(scope, {
                Thickness = 2.8,
                Enabled = true,

                Color = Tween(scope, Computed(scope, function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            }),
            Components.HoverImageButton(scope, {
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
            Components.ImageLabel(scope, {
                Name = "Icon",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.026, 0.5),
                Size = fromScale(0.072, 0.8),
                Image = AssetBook.PromptIcons[icon],

                ImageColor3 = Tween(scope, Computed(scope, function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            }),
            Components.TextLabel(scope, {
                Name = "OptionText",
                Position = fromScale(0.528, 0.5),
                Size = fromScale(0.8, 0.7),
                Text = option,
                AnchorPoint = v2New(0.5, 0.5),
		        TextXAlignment = Enum.TextXAlignment.Left,

                TextColor3 = Tween(scope, Computed(scope, function(use)
                    return use(contentColor)
                end), AssetBook.TweenInfos.threeHalf)
            })
        }
    })
end

return ChatOption
