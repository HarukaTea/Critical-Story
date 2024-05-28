--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")

local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Cmdr = require(RepS:WaitForChild("CmdrClient", 999))

local plr = Players.LocalPlayer

local cfAngles = CFrame.Angles
local rad = math.rad
local wait = task.wait

local function openAcquiredChests()
    local chests = workspace:WaitForChild("MapComponents", 999).Chests :: Folder
    local inventory = plr:WaitForChild("Inventory", 999) :: Folder

    for _, chest: Model in chests:GetChildren() do
        if inventory:FindFirstChild(chest.Name) then
            if chest:GetAttribute("Active") then if not chest:GetAttribute(plr.Name) then continue end end

            chest:SetAttribute("Opened", true)
            chest.Giver.Chest.Enabled = false

            chest.Top:PivotTo(chest.Top.PrimaryPart.CFrame * cfAngles(rad(50), 0, 0))
        end
    end
end
Spawn(openAcquiredChests)


local function cmdrRegister()
    Cmdr:SetActivationKeys({ Enum.KeyCode.Quote })
    Cmdr:SetPlaceName("CStory-0.8")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end
Spawn(cmdrRegister)


local function disableDefaultFreecam()
    repeat wait() until plr.PlayerGui:WaitForChild("Freecam", 999)

    plr.PlayerGui.Freecam:Destroy()

    repeat wait() until plr.PlayerGui:WaitForChild("BubbleChat", 999)

    plr.PlayerGui.BubbleChat:Destroy()
end
Spawn(disableDefaultFreecam)


local function errorReports()
    local function _errored(msg: string, _, _)
        local newError = Instance.new("StringValue")
        newError.Name = "Client"
        newError.Value = msg
        newError:SetAttribute("Owner", plr.Name)
        newError.Parent = workspace.MapComponents.ScriptErrors
    end
    ScriptContext.Error:Connect(_errored)
end
Spawn(errorReports)
