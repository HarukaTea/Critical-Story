--!nocheck

local CP = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RepS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer

local fromScale = UDim2.fromScale
local instanceNew = Instance.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local wait, spawn = task.wait, task.spawn
local cfNew = CFrame.new
local tweenInfoNew = TweenInfo.new

--// Disable CoreUIs
local function coreUISetup()
    ReplicatedFirst:RemoveDefaultLoadingScreen()

    SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end
coreUISetup()

local loadFinished = false
local function setup()
    -- auto-generated by `Condify`
    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "LoadingScreen"
    loadingScreen.DisplayOrder = 10
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    loadingScreen.ResetOnSpawn = false
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local bG = Instance.new("Frame")
    bG.Name = "BG"
    bG.AnchorPoint = Vector2.new(0.5, 0.5)
    bG.BackgroundColor3 = Color3.fromRGB(223, 223, 223)
    bG.BorderColor3 = Color3.fromRGB(0, 0, 0)
    bG.BorderSizePixel = 0
    bG.Position = UDim2.fromScale(0.5, 0.5)
    bG.Size = UDim2.fromScale(1, 1)

    local loadingTip = Instance.new("TextLabel")
    loadingTip.Name = "LoadingTip"
    loadingTip.FontFace = Font.new(
        "rbxasset://fonts/families/SourceSansPro.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    loadingTip.Text = "LOADING ADVENTURE..."
    loadingTip.TextColor3 = Color3.fromRGB(0, 0, 0)
    loadingTip.TextScaled = true
    loadingTip.TextSize = 14
    loadingTip.TextWrapped = true
    loadingTip.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingTip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    loadingTip.BackgroundTransparency = 1
    loadingTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
    loadingTip.BorderSizePixel = 0
    loadingTip.Position = UDim2.fromScale(0.5, 0.5)
    loadingTip.Size = UDim2.fromScale(1, 0.07)

    local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint.Name = "UITextSizeConstraint"
    uITextSizeConstraint.MaxTextSize = 36
    uITextSizeConstraint.Parent = loadingTip

    loadingTip.Parent = bG
    bG.Parent = loadingScreen
    loadingScreen.Parent = plr.PlayerGui

    task.delay(9, function()
        if loadFinished then return end

        loadingTip.Text = "ADVENTURE IS TAKING LONGER TO LOAD..."
    end)
    task.delay(20, function()
        if loadFinished then return end

        loadingTip.Text = "ADVENTURE IS STILL LOADING..."
    end)

    spawn(function()
        CP:PreloadAsync({ "rbxassetid://17301878871" })
    end)

    repeat wait() until plr:GetAttribute("PlayerDataLoaded")

    loadingTip.Text = "ADVENTURE LOADED!"

    loadFinished = true
    print("Load Finished")

    --- fade out
    Debris:AddItem(loadingScreen, 0.5)
    if workspace:GetAttribute("WorldType") == "Mainworld" and plr.Quests.Main.Value == 1 then return end

    local halfTween = TweenInfo.new(0.5)
    TS:Create(loadingTip, halfTween, { TextTransparency = 1 }):Play()
    TS:Create(bG, halfTween, { BackgroundTransparency = 1 }):Play()
end
setup()

local function storylineSetup()
    --// Story cutscene if first join
    if workspace:GetAttribute("WorldType") ~= "Mainworld" then return end
    if plr.Quests.Main.Value ~= 1 then return end

    local Signals = require(RepS.Modules.Data.Signals)

    local sound = workspace:WaitForChild("Sounds", 999).Overworld :: Sound
    local playThread = task.spawn(function()
        while true do
            task.wait()
            sound.Volume = 0
        end
    end)
    workspace.Sounds.StoryMusics.Cairn:Play()

    plr:SetAttribute("InCutscene", true)

    -- load white overlay
    local cutsceneUI = instanceNew("ScreenGui")
    cutsceneUI.Name = "TempCutscene"
    cutsceneUI.DisplayOrder = 100
    cutsceneUI.IgnoreGuiInset = true
    cutsceneUI.Parent = plr:FindFirstChildOfClass("PlayerGui")

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
    camera.CameraSubject = workspace:WaitForChild("Maps", 999).StartCutscene.CameraLocator1
    camera.CFrame = workspace.Maps.StartCutscene.CameraLocator1.CFrame

    plr:FindFirstChildOfClass("PlayerGui"):WaitForChild("NPCChat", 999)

    repeat wait() until plr.Character or plr.CharacterAdded:Wait()

    plr.Character:PivotTo(workspace:WaitForChild("Maps", 999).StartCutscene.CutsceneLocator.CFrame)
    plr.Character:SetAttribute("CurrentRegion", "")
    workspace.Maps.Ocean.Parent = RepS.Debris

    wait(5)
    Signals.EnterNPCChat:Fire(workspace:WaitForChild("MapComponents", 999).NPCs.Pioxit1)

    Debris:AddItem(cutsceneUI, 1)
    TS:Create(cutsceneBG, tweenInfoNew(1), { BackgroundTransparency = 1 }):Play()

    Signals.StoryMain1:Once(function()
        if playThread then task.cancel(playThread) end
    end)
end
storylineSetup()
