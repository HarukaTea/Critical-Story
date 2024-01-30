--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local UGS = UserSettings():GetService("UserGameSettings")

local Cmdr = require(RepS:WaitForChild("CmdrClient"))
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local maps = workspace:WaitForChild("Maps")
local mapComponents = workspace:WaitForChild("MapComponents")

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad
local yAxis = Vector3.yAxis

local function enableWorldAnims()
    for _, child in maps:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
            Spawn(function()
                Clock(0.01, function()
                    child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1), 0, 0))
                end)
            end)

        elseif child.Name == "Sky Galleon" then
            Spawn(function()
                while true do
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame + yAxis * 0.03)
                        wait(0.01)
                    end
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame - yAxis * 0.03)
                        wait(0.01)
                    end
                end
            end)
        end
    end
end

local function dayNightCycle()
    local cycleTime, minutesInADay = 12 * 60, 24 * 60
    local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime
    local endTime = startTime + cycleTime
    local timeRatio, currentTime = minutesInADay / cycleTime, nil

    Clock(0.05, function()
        currentTime = tick()

        if currentTime > endTime then
            startTime = endTime
            endTime = startTime + cycleTime
        end

        Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
    end)
end

local function openAcquiredChests(plr: Player)
    local chests = mapComponents.Chests
    local inventory = plr:WaitForChild("Inventory", 999)

    for _, chest in chests:GetChildren() do
        if inventory:FindFirstChild(chest.Name) then
            chest:SetAttribute("Opened", true)
            chest.Giver.Chest.Enabled = false

            Spawn(function()
                for _ = 1, 5 do
                    wait(0.01)
                    chest.Top:PivotTo(chest.Top.Base.CFrame * cfAngles(rad(10), 0, 0))
                end
            end)
        end
    end
end

local function cmdrRegister(plr: Player)
    Cmdr:SetActivationKeys({ Enum.KeyCode.Quote })
    Cmdr:SetPlaceName("CS-Test-0.7")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end

local function cameraSensitivityChange()
    UIS.MouseDeltaSensitivity = 0.74 / UGS.MouseSensitivity

    UGS:GetPropertyChangedSignal("MouseSensitivity"):Connect(function()
        UIS.MouseDeltaSensitivity = 0.74 / UGS.MouseSensitivity
    end)
end

local function returnFunc(plr: Player)
    local UIModules = RepS.Modules.UI
    local requireList = {
        UIModules.Hints,
        UIModules.PostStroke
    }
    HarukaLib:Require(requireList, plr)

    enableWorldAnims()
    dayNightCycle()
    openAcquiredChests(plr)
    cmdrRegister(plr)
    cameraSensitivityChange()
end

return returnFunc
