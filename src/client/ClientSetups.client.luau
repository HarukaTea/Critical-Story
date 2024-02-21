--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local UGS = UserSettings():GetService("UserGameSettings")

local Cmdr = require(RepS:WaitForChild("CmdrClient"))
local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local wait = task.wait
local cfAngles = CFrame.Angles
local rad = math.rad

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
