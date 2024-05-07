--!nocheck
--!optimize 2
--!native

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)
local SuperTween = require(RepS.Modules.Packages.SuperTween)

local Cmdr = require(RepS:WaitForChild("CmdrClient"))

local plr = Players.LocalPlayer

local cfAngles = CFrame.Angles
local rad = math.rad

local function openAcquiredChests()
    local chests = workspace:WaitForChild("MapComponents").Chests :: Folder
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    for _, chest: Model in chests:GetChildren() do
        if inventory:FindFirstChild(chest.Name) then
            if chest:GetAttribute("Active") then if not chest:GetAttribute(plr.Name) then continue end end

            chest:SetAttribute("Opened", true)
            chest.Giver.Chest.Enabled = false

            SuperTween.new(chest.Top, AssetBook.TweenInfos.twiceHalf, { Pivot = chest.Top.PrimaryPart.CFrame * cfAngles(rad(50), 0, 0) }):Play()
        end
    end
end
Spawn(openAcquiredChests)


local function dayNightCycle()
    local cycleTime, minutesInADay = 12 * 60, 24 * 60
    local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime
    local endTime = startTime + cycleTime
    local timeRatio, currentTime = minutesInADay / cycleTime, nil

    HarukaLib.Clock(0.05, function()
        currentTime = tick()

        if currentTime > endTime then
            startTime = endTime
            endTime = startTime + cycleTime
        end

        Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
    end)
end
Spawn(dayNightCycle)


local function cmdrRegister()
    Cmdr:SetActivationKeys({ Enum.KeyCode.Quote })
    Cmdr:SetPlaceName("CStory-0.8")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end
Spawn(cmdrRegister)
