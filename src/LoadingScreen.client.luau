--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RF = game:GetService("ReplicatedFirst")
local RepS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer

local wait, delay = task.wait, task.delay
local udNew, fromScale = UDim.new, UDim2.fromScale
local newInstance, newTweenInfo = Instance.new, TweenInfo.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local fontFromName = Font.fromName

RF:RemoveDefaultLoadingScreen()
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

local loadFinished = false

--- create a default blackscreen before fusion loads
local ui = newInstance("ScreenGui")
ui.Name = "Loading"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 100
ui.Parent = plr.PlayerGui

local bg = newInstance("Frame")
bg.Name = "BG"
bg.BackgroundColor3 = fromRGB(30, 30, 30)
bg.AnchorPoint = v2New(0.5, 0.5)
bg.Size = fromScale(1, 1)
bg.Position = fromScale(0.5, 0.5)
bg.Parent = ui

local bottomBG = newInstance("Frame")
bottomBG.Name = "Bottom"
bottomBG.BackgroundTransparency = 1
bottomBG.AnchorPoint = v2New(0.5, 0.9)
bottomBG.Position = fromScale(0.5, 1)
bottomBG.Size = fromScale(1, 0.1)
bottomBG.Parent = bg

local uiAspect = newInstance("UIAspectRatioConstraint")
uiAspect.AspectRatio = 25.129
uiAspect.Parent = bottomBG

--- loading progress bar
local bar = newInstance("Frame")
bar.Name = "ProgressBar"
bar.BackgroundColor3 = fromRGB(217, 193, 144)
bar.Position = fromScale(0, -0.5)
bar.Size = fromScale(0, 0.1)
bar.Parent = bottomBG

--- loading text
local textLabel = newInstance("TextLabel")
textLabel.Name = "ProgressText"
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0, -1.3)
textLabel.Size = fromScale(1, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = fromRGB(217, 193, 144)
textLabel.FontFace = fontFromName("Roboto", Enum.FontWeight.Bold)
textLabel.Parent = bottomBG

local textSizeConstraint = newInstance("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 36
textSizeConstraint.Parent = textLabel

--- classes
local classBG = newInstance("Frame")
classBG.AnchorPoint = v2New(0.5, 0)
classBG.BackgroundTransparency = 1
classBG.Position = fromScale(0.5, -0.2)
classBG.Size = fromScale(1, 0.75)
classBG.Parent = bottomBG

local uiList = newInstance("UIListLayout")
uiList.Padding = udNew(0.003, 0)
uiList.FillDirection = Enum.FillDirection.Horizontal
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.Parent = classBG

local classes = {
    "rbxassetid://2965862892",
    "rbxassetid://2965863905",
    "rbxassetid://2965863231",
    "rbxassetid://2965863677",
    "rbxassetid://12284961892",
    "rbxassetid://12190533959",
    "rbxassetid://12190535870",
    "rbxassetid://12236618949",
    "rbxassetid://15875390788",
    "rbxassetid://16654290906"
}
local classImages = {}
for index, class in classes do
    local image = newInstance("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = fromScale(1, 1)
    image.SizeConstraint = Enum.SizeConstraint.RelativeYY
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

delay(9, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is taking longer than expected..."
end)
delay(30, function()
    if loadFinished then return end

    textLabel.Text = "Adventure load failed...Datastore may be having issues right now..."

    wait(1)
    require(RepS.Modules.Data.Events).ErrorDataStore:Fire()
end)

--- wait until data loads
local halfTween, sixTween = newTweenInfo(0.5), newTweenInfo(6)
TS:Create(bar, sixTween, { Size = fromScale(0.6, 0.1) }):Play()

plr:WaitForChild("Inventory", 999)
print("Load Finished")

textLabel.Text = "Adventure Loaded!"
loadFinished = true

wait(1)
TS:Create(bar, halfTween, { Size = fromScale(1, 0.1), BackgroundTransparency = 1 }):Play()
TS:Create(textLabel, halfTween, { TextTransparency = 1 }):Play()
TS:Create(bg, halfTween, { BackgroundTransparency = 1 }):Play()
for _, class in classImages do
    TS:Create(class, halfTween, { ImageTransparency = 1 }):Play()
end

wait(1.5)
ui:Destroy()
script:Destroy()
