--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundS = game:GetService("SoundService")
local TS = game:GetService("TweenService")
local TestS = game:GetService("TestService")

local Signals = require(RepS.Modules.Data.Signals)

local wait = task.wait
local instanceNew = Instance.new
local tweenInfoNew = TweenInfo.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local fromScale = UDim2.fromScale


local function startAdventure(plr: Player)
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
    plr.Character:PivotTo(workspace.Maps.MonolithVillage.SpawnPoint.CFrame)
    plr.Character:SetAttribute("CurrentRegion", "MonolithVillage")
    plr:SetAttribute("InCutscene", nil)

    Debris:AddItem(cutsceneUI, 1)
    TS:Create(cutsceneBG, tweenInfoNew(1), { BackgroundTransparency = 1 }):Play()

    TestS.Ocean.Parent = workspace.Maps
    TS:Create(SoundS.Musics, tweenInfoNew(1), { Volume = 0.5 }):Play()
    TS:Create(workspace.Sounds.StoryMusics.Cairn, tweenInfoNew(1), { Volume = 0 }):Play()

    workspace.Sounds.Overworld:Play()
    wait(2)
    workspace.Sounds.StoryMusics.Cairn:Stop()
end
Signals.StoryMain1:Connect(startAdventure)
