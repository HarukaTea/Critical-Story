--!nocheck

local Players = game:GetService("Players")
local RF = game:GetService("ReplicatedFirst")
local RepS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer

local wait, delay = task.wait, task.delay
local ud2New, fromOffset, fromScale = UDim2.new, UDim2.fromOffset, UDim2.fromScale
local newInstance, newColor3, newTweenInfo = Instance.new, Color3.new, TweenInfo.new
local fromHex = Color3.fromHex

RF:RemoveDefaultLoadingScreen()
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)

--- create a default blackscreen before fusion loads
local ui = newInstance("ScreenGui")
ui.Name = "Temp"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.Parent = plr.PlayerGui

local frame = newInstance("Frame")
frame.BackgroundColor3 = fromHex("#1e1e1e")
frame.Size = ud2New(1, 0, 1, 58)
frame.Position = fromOffset(0, -58)
frame.Parent = ui

local textLabel = newInstance("TextLabel")
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0.02, 0.91)
textLabel.Size = fromScale(0.96, 0.05)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = newColor3(1, 1, 1)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
textLabel.Parent = frame

local textSizeConstraint = newInstance("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 32
textSizeConstraint.Parent = textLabel

delay(5, function()
    textLabel.Text = "Adventure is taking longer than expected..."
end)
delay(15, function()
    textLabel.Text = "Adventure load failed, teleporting back..."

    wait(1)
    require(RepS.Modules.HarukaFrameworkClient).Events.ErrorDataStore:Fire()
end)

--- wait until data loads
plr:WaitForChild("Inventory", 999)

textLabel.Text = ""
TS:Create(frame, newTweenInfo(0.5), { BackgroundTransparency = 1 }):Play()

wait(1.5)
ui:Destroy()
script:Destroy()
