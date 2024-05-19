--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local DeviceGetter = require(RepS.Modules.Packages.DeviceGetter)
local Fusion = require(RepS.Modules.Packages.Fusion)

local isMobile = DeviceGetter:IsPhone() or DeviceGetter:IsTablet()

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function Prompt(prompt: ProximityPrompt, index: number, scope: table) : Frame
    return Components.Frame(scope, {
        Name = "Prompt",
        AnchorPoint = v2New(0.5, 0),
        BackgroundTransparency = 0,
        Size = fromScale(0.158, 1),

        [Fusion.Children] = {
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 2.5,
                Enabled = if index == 1 then true else false
            }),
            Components.ImageLabel(scope, {
                Name = "Icon",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.05, 0.5),
                Size = fromScale(0.12, 0.7),
                Image = if AssetBook.PromptIcons[prompt.Name] then AssetBook.PromptIcons[prompt.Name] else AssetBook.PromptIcons.Chat
            }),
            Components.TextLabel(scope, {
                Name = "PromptText",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.23, 0.5),
                Size = fromScale(0.77, 0.7),
                Text = prompt.ActionText,
		        TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Components.TextLabel(scope, {
                Name = "Key",
                Position = fromScale(-0.22, 0),
                Size = fromScale(0.17, 1),
                Text = "E",
                Visible = if index == 1 and not isMobile then true else false,

                [Fusion.Children] = {
                    Components.TextUIStroke(scope, { Thickness = 4 })
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