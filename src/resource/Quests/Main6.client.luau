--!nocheck

if workspace:GetAttribute("WorldType") ~= "Mainworld" then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientUtil = require(ReplicatedStorage.Modules.Utils.ClientUtil)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Signals = require(ReplicatedStorage.Modules.Data.Signals)

local Add, Empty = HarukaLib.Bin()

local plr = Players.LocalPlayer

--// clear any tagged locators
for _, locator: BasePart in workspace:WaitForChild("Monsters", 999):GetDescendants() do
    if locator:IsA("BasePart") and locator:GetAttribute("_STORY_Main6") then
        locator:SetAttribute("ExclusivePlayer", "Nobody")
        locator.Parent = ReplicatedStorage.Debris
    end
end

--// Move paho there
local locator = workspace:WaitForChild("Maps", 999).MonolithGrove.StoryLocator1 :: BasePart
local paho = workspace:WaitForChild("MapComponents", 999).NPCs.Paho :: Model

paho:PivotTo(locator.CFrame)

--// detect distance
Add(HarukaLib.Clock(0.5, function()
    local distance = plr:DistanceFromCharacter(locator.Position)

    if distance < 59.99 and distance > 0 then
        paho:PivotTo(locator.CFrame)

        Signals.CameraScene:Fire(locator.Parent.StoryCamera1)
        Signals.PlaySound:Fire(ReplicatedStorage.Package.Unloads.ResetSound)

        workspace.Sounds.StoryMusics.Lancer:Play()

        ClientUtil:FreezePlayerControls("Freeze")
        plr.Character:PivotTo(locator.Parent.StoryLocator2.CFrame)

        Signals.EnterNPCChat:Fire(workspace.MapComponents.NPCs.Paho)

        Empty()
    end
end))
