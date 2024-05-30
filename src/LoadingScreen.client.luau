--!nocheck

local CP = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local SoundS = game:GetService("SoundService")
local TS = game:GetService("TweenService")
local TestS = game:GetService("TestService")

local plr = Players.LocalPlayer

local fromScale = UDim2.fromScale
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local fontFromName = Font.fromName
local wait, delay, spawn = task.wait, task.delay, task.spawn
local cfNew = CFrame.new
local tweenInfoNew = TweenInfo.new
local udNew = UDim.new

--// Disable CoreUIs
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

local loadFinished = false

---// create a default blackscreen before fusion loads
local ui = instanceNew("ScreenGui")
ui.Name = "Loading"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 100
ui.Parent = plr.PlayerGui

local bg = instanceNew("Frame")
bg.Name = "BG"
bg.BackgroundColor3 = fromRGB(30, 30, 30)
bg.AnchorPoint = v2New(0.5, 0.5)
bg.Size = fromScale(1, 1)
bg.Position = fromScale(0.5, 0.5)
bg.Parent = ui

local bottomBG = instanceNew("Frame")
bottomBG.Name = "Bottom"
bottomBG.BackgroundTransparency = 1
bottomBG.AnchorPoint = v2New(0.5, 0.9)
bottomBG.Position = fromScale(0.5, 1)
bottomBG.Size = fromScale(1, 0.1)
bottomBG.Parent = bg

local uiAspect = instanceNew("UIAspectRatioConstraint")
uiAspect.AspectRatio = 25.129
uiAspect.Parent = bottomBG

--- loading progress bar
local bar = instanceNew("Frame")
bar.Name = "ProgressBar"
bar.BackgroundColor3 = fromRGB(217, 193, 144)
bar.Position = fromScale(0, -0.5)
bar.Size = fromScale(0, 0.1)
bar.Parent = bottomBG

--- loading text
local textLabel = instanceNew("TextLabel")
textLabel.Name = "ProgressText"
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0, -1.3)
textLabel.Size = fromScale(1, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = fromRGB(217, 193, 144)
textLabel.FontFace = fontFromName("Roboto", Enum.FontWeight.Bold)
textLabel.Parent = bottomBG

local textSizeConstraint = instanceNew("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 36
textSizeConstraint.Parent = textLabel

--- classes
local classBG = instanceNew("Frame")
classBG.AnchorPoint = v2New(0.5, 0)
classBG.BackgroundTransparency = 1
classBG.Position = fromScale(0.5, -0.2)
classBG.Size = fromScale(1, 0.75)
classBG.Parent = bottomBG

local uiList = instanceNew("UIListLayout")
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
    "rbxassetid://16654290906",
    "rbxassetid://17667241921"
}
local classImages = {}
for index, class in classes do
    local image = instanceNew("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = fromScale(1, 1)
    image.SizeConstraint = Enum.SizeConstraint.RelativeYY
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

delay(9, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is loading longer than expected..."
end)
delay(20, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is loading so hard with a high ping..."
end)

--- wait until data loads
TS:Create(bar, tweenInfoNew(6), { Size = fromScale(0.6, 0.1) }):Play()

spawn(function()
    CP:PreloadAsync({ "rbxassetid://17301878871" })
end)

repeat wait() until plr:GetAttribute("PlayerDataLoaded")

textLabel.Text = "Adventure Data Loaded!"

loadFinished = true
print("Load Finished")

Debris:AddItem(ui, 0.5)
TS:Create(bar, tweenInfoNew(0.5), { Size = fromScale(1, 0.1), BackgroundTransparency = 1 }):Play()
TS:Create(textLabel, tweenInfoNew(0.5), { TextTransparency = 1 }):Play()
TS:Create(bg, tweenInfoNew(0.5), { BackgroundTransparency = 1 }):Play()
for _, class: ImageLabel in classImages do
    TS:Create(class, tweenInfoNew(0.5), { ImageTransparency = 1 }):Play()
end

--// Story cutscene if first join
if workspace:GetAttribute("WorldType") ~= "Mainworld" then return end
if plr.Quests.Main.Value ~= 1 then return end

local Signals = require(RepS.Modules.Data.Signals)

-- load white overlay
local cutsceneUI = instanceNew("ScreenGui")
cutsceneUI.Name = "TempCutscene"
cutsceneUI.DisplayOrder = 100
cutsceneUI.IgnoreGuiInset = true
cutsceneUI.Parent = plr.PlayerGui

local cutsceneBG = instanceNew("Frame")
cutsceneBG.BackgroundColor3 = fromRGB(234, 234, 234)
cutsceneBG.AnchorPoint = v2New(0.5, 0.5)
cutsceneBG.Position = fromScale(0.5, 0.5)
cutsceneBG.Size = fromScale(1, 1)
cutsceneBG.BackgroundTransparency = 1
cutsceneBG.Parent = cutsceneUI
TS:Create(cutsceneBG, tweenInfoNew(0.5), { BackgroundTransparency = 0 }):Play()

wait(1)
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cfNew(-9997, 54.6, 9991.6, -0.5, 0, 0.8, -0, 1, 0, -0.84, 0, -0.53)
plr:SetAttribute("InCutscene", true)

SoundS.Musics.Volume = 0
workspace.Sounds.StoryMusics.Cairn:Play()

plr.PlayerGui:WaitForChild("NPCChat", 999)

repeat wait() until plr.Character

plr.Character:PivotTo(workspace:WaitForChild("Maps", 999).StartCutscene.CutsceneLocator.CFrame)
plr.Character:SetAttribute("CurrentRegion", "")
workspace.Maps.Ocean.Parent = TestS

wait(5)
Signals.StartNPCChat:Fire(workspace:WaitForChild("MapComponents", 999).NPCs.Pioxit1, RepS.Package.Unloads.FakePrompt)

Debris:AddItem(cutsceneUI, 1)
TS:Create(cutsceneBG, tweenInfoNew(1), { BackgroundTransparency = 1 }):Play()
