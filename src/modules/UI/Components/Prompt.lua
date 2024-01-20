--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local Fusion = HarukaFrameworkClient.Fusion

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function Prompt(prompt: ProximityPrompt, index: number) : Frame
    return Components.Frame({
        Name = "Prompt",
        AnchorPoint = v2New(0.5, 0),
        BackgroundTransparency = 0,
        Size = fromScale(0.158, 1),

        [Fusion.Children] = {
            Components.RoundUICorner(),
            Components.UIStroke({
                Thickness = 2.5,
                Enabled = if index == 1 then true else false
            }),
            Components.ImageLabel({
                Name = "Icon",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.05, 0.5),
                Size = fromScale(0.12, 0.7),
                Image = "rbxassetid://13124035950"
            }),
            Components.CenterTextLabel({
                Name = "PromptText",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.23, 0.5),
                Size = fromScale(0.77, 0.7),
                Text = prompt.ActionText
            }),
            Components.TextLabel({
                Name = "Key",
                Position = fromScale(-0.22, 0),
                Size = fromScale(0.17, 1),
                Text = "E",
                Visible = if index == 1 and not UIS.TouchEnabled then true else false,

                [Fusion.Children] = {
                    Components.TextUIStroke({ Thickness = 4 })
                }
            }),
            Components.HoverImageButton({
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    prompt:InputHoldBegin()
                end
            })
        }
    })
end

return Prompt