--!nocheck

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local UGS = UserSettings():GetService("UserGameSettings")

local Cmdr = require(RepS:WaitForChild("CmdrClient"))
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad
local yAxis = Vector3.yAxis

local function openAcquiredChests()
    local chests = workspace:WaitForChild("MapComponents").Chests :: Folder
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    for _, chest: Model in chests:GetChildren() do
        if inventory:FindFirstChild(chest.Name) then
            chest:SetAttribute("Opened", true)
            chest.Giver.Chest.Enabled = false

            Spawn(function()
                for _ = 1, 5 do
                    wait(0.01)
                    chest.Top:PivotTo(chest.Top.PrimaryPart.CFrame * cfAngles(rad(10), 0, 0))
                end
            end)
        end
    end
end
openAcquiredChests()


local function cmdrRegister()
    Cmdr:SetActivationKeys({ Enum.KeyCode.Quote })
    Cmdr:SetPlaceName("CStory-0.7")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end
cmdrRegister()


local function cameraSensitivityChange()
    UIS.MouseDeltaSensitivity = 0.7 / UGS.MouseSensitivity
end
cameraSensitivityChange()
UGS:GetPropertyChangedSignal("MouseSensitivity"):Connect(cameraSensitivityChange)


local function enableWorldAnims()
	local world = workspace:WaitForChild("Maps")

    for _, child in world:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
			Clock(0.01, function()
				child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1.5), 0, 0))
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
enableWorldAnims()


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
dayNightCycle()


local function setupUI()
    local UIModules = RepS.Modules.UI
    local requireList = {
        UIModules.Hints,
        UIModules.PostStroke,
        UIModules.PlayerList
    }
    for _, module in requireList do
        Spawn(function()
            require(module)(plr)
        end)
    end
end
setupUI()
