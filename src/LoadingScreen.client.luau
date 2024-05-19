--!nocheck

local Players = game:GetService("Players")
local SG = game:GetService("StarterGui")

local plr = Players.LocalPlayer

local fromScale = UDim2.fromScale
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local fontFromEnum = Font.fromEnum

--// Disable CoreUIs
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

--// Loading tip
local tempUI = instanceNew("ScreenGui")
tempUI.Name = "Temp"
tempUI.DisplayOrder = 100
tempUI.Parent = plr.PlayerGui

local hint = instanceNew("TextLabel")
hint.Name = "LoadingHint"
hint.AnchorPoint = v2New(0.5, 1)
hint.Position = fromScale(0.5, 0.9)
hint.BackgroundTransparency = 1
hint.Size = fromScale(1, 0.05)
hint.FontFace = fontFromEnum(Enum.Font.SourceSansBold)
hint.Text = "Loading Data..."
hint.TextScaled = true
hint.TextColor3 = fromRGB(255, 255, 255)
hint.Parent = tempUI

local uiTextSizeLimit = instanceNew("UITextSizeConstraint")
uiTextSizeLimit.MaxTextSize = 35
uiTextSizeLimit.Parent = hint

local textStroke = instanceNew("UIStroke")
textStroke.Thickness = 3
textStroke.Transparency = 0.3
textStroke.Parent = hint

plr:WaitForChild("Inventory", 999)

print("Load Finished")

tempUI:Destroy()
script:Destroy()
