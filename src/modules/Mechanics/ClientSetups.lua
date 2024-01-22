--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local UGS = UserSettings():GetService("UserGameSettings")

local Cmdr = require(RepS:WaitForChild("CmdrClient"))
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local FastSpawn = require(RepS.Modules.Packages.Spawn)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ClientSetups = {}
ClientSetups.__index = ClientSetups

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad
local yAxis = Vector3.yAxis

--[[
    Start the animate models, such as Windmill and Sky galleons
]]
function ClientSetups:EnableWorldAnims()
    for _, child in self.maps:GetDescendants() do
        if child.Name == "Wings" and child.Parent.Name == "Windmill" then
            FastSpawn(function()
                Clock(0.01, function()
                    child:PivotTo(child.PrimaryPart.CFrame * cfAngles(rad(-1), 0, 0))
                end)
            end)

        elseif child.Name == "Sky Galleon" then
            FastSpawn(function()
                while true do
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame + yAxis * 0.01)
                        wait(0.01)
                    end
                    for _ = 1, 100 do
                        child:PivotTo(child.PrimaryPart.CFrame - yAxis * 0.01)
                        wait(0.01)
                    end
                end
            end)
        end
    end
end

--[[
    Enable day-night cycle mechanic, day night cycles every 12 minutes
]]
function ClientSetups:DayNightCycle()
    local cycleTime, minutesInADay = self.CYCLE_TIME, self.MINUTES_IN_A_DAY
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

--[[
    Detect if the chest is opened, when player joins
]]
function ClientSetups:OpenAcquiredChests(plr: Player)
    local chests = self.mapComponents.Chests
    local inventory = plr:WaitForChild("Inventory", 999)

    for _, chest in chests:GetChildren() do
        if inventory:FindFirstChild(chest.Name) then
            chest:SetAttribute("Opened", true)
            chest.Giver.Chest.Enabled = false

            FastSpawn(function()
                for i = 1, 5 do
                    wait(0.01)
                    chest.Top:PivotTo(chest.Top.Base.CFrame * cfAngles(rad(10), 0, 0))
                end
            end)
        end
    end
end

--[[
    Register cmdr in client, and along with chat detections
]]
function ClientSetups:CmdrRegister(plr: Player)
    Cmdr:SetActivationKeys({ Enum.KeyCode.P })
    Cmdr:SetPlaceName("CS-Test-0.7")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end

--[[
    Default camera sensitivity is a little higher, and we wanna change that
]]
function ClientSetups:CameraSensitivityChange()
    UIS.MouseDeltaSensitivity = 0.8 / UGS.MouseSensitivity

    UGS:GetPropertyChangedSignal("MouseSensitivity"):Connect(function()
        UIS.MouseDeltaSensitivity = 0.8 / UGS.MouseSensitivity
    end)
end

return function (plr: Player)
    local self = setmetatable({}, ClientSetups)

    self.maps = workspace:WaitForChild("Maps")
    self.mapComponents = workspace:WaitForChild("MapComponents")

    self.CYCLE_TIME, self.MINUTES_IN_A_DAY = 12 * 60, 24 * 60

    local UIModules = RepS.Modules.UI
    local requireList = {
        UIModules.Hints,
        UIModules.PostStroke,
        UIModules.AdventurerMenu,
        UIModules.Backpack,
        UIModules.PlayerList,
        RepS.Modules.Mechanics.MonsterVFX,
    }
    HarukaLib:Require(requireList, plr)

    self:EnableWorldAnims()
    self:DayNightCycle()
    self:OpenAcquiredChests(plr)
    self:CmdrRegister(plr)
    self:CameraSensitivityChange()
end
