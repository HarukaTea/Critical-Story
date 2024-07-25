--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Fusion = require(RepS.Modules.Packages.Fusion)

local isMobile = HarukaLib:GetDevice() == "Mobile"

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new

local function Prompt(prompt: ProximityPrompt, index: number, scope: Fusion.Scope, self: table) : Frame
    return Components.Frame(scope, {
        Name = "Prompt",
        AnchorPoint = v2New(0.5, 0),
        BackgroundTransparency = 0,
        Size = fromScale(0.18, 1),
        LayoutOrder = prompt:GetAttribute("Order") or 1,

        [Fusion.Children] = {
            Components.RoundUICorner(scope),
            Fusion.New(scope, "UIGradient")({
                Transparency = nsNew({ nsKPNew(0, 0), nsKPNew(0.5, 0.2), nsKPNew(1, 1) }),
            }),
            Components.UIStroke(scope, {
                Thickness = 3,
                Transparency = 0.3,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(self.currentPromptIndex) == index then true else false
                end),

                [Fusion.Children] = {
                    Fusion.New(scope, "UIGradient")({
                        Transparency = nsNew({ nsKPNew(0, 0), nsKPNew(0.5, 0.2), nsKPNew(0.9, 1), nsKPNew(1, 1) }),
                    })
                }
            }),

            Components.ImageLabel(scope, {
                Name = "Icon",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.05, 0.5),
                Size = fromScale(0.7, 0.7),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = AssetBook.PromptIcons[prompt.Name] or AssetBook.PromptIcons.Chat
            }),
            Components.TextLabel(scope, {
                Name = "PromptText",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.19, 0.5),
                Size = fromScale(0.77, 0.7),
                Text = prompt.ActionText,
		        TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(-0.18, 0.5),
                Size = fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = prompt.KeyboardKeyCode.Name,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(self.currentPromptIndex) == index and not isMobile then true else false
                end),

                [Fusion.Children] = {
                    Components.TextUIStroke(scope, { Thickness = 3 })
                }
            }),
            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    prompt:InputHoldBegin()
                end
            })
        }
    })
end

return Prompt