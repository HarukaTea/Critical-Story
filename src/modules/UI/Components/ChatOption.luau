--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent, Children, New = Fusion.OnEvent, Fusion.Children, Fusion.New

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local v2New = Vector2.new
local sub = string.sub
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new

local function ChatOption(option: string, icon: string, self: table, index: number, scope: Fusion.Scope) : Frame
    local isSelecting = Fusion.Value(scope, false)

    if icon ~= "Chat" then option = sub(option, #icon + 2) end

    return Components.Frame(scope, {
        BackgroundTransparency = 0,
        Size = fromScale(0.9, 0.27),

        [Children] = {
            New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
            Components.UIStroke(scope, {
                Thickness = 2.8,

                Enabled = Fusion.Computed(scope, function(use)
                    return use(isSelecting)
                end),

                [Children] = {
                    New(scope, "UIGradient")({
                        Transparency = nsNew({nsKPNew(0, 0), nsKPNew(0.7, 0.2), nsKPNew(1, 1)})
                    })
                }
            }),
            New(scope, "UIGradient")({
                Transparency = nsNew({nsKPNew(0, 0), nsKPNew(0.5, 0.2), nsKPNew(1, 1)})
            }),
            Components.HoverImageButton(scope, {
                [OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
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
                Position = fromScale(0.03, 0.5),
                Size = fromScale(0.059, 0.6),
                Image = AssetBook.PromptIcons[icon]
            }),
            Components.TextLabel(scope, {
                Name = "OptionText",
                Position = fromScale(0.687, 0.5),
                Size = fromScale(1.118, 0.7),
                Text = option,
                AnchorPoint = v2New(0.5, 0.5),
		        TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = {
                    New(scope, "UIPadding")({
                        PaddingTop = udNew(0.05, 0),
                        PaddingBottom = udNew(0.05, 0)
                    }),
                    Components.TextUIStroke(scope, { Thickness = 1.5 })
                }
            })
        }
    })
end

return ChatOption
