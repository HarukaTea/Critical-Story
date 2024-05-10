--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
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


local function cmdrRegister()
    Cmdr:SetActivationKeys({ Enum.KeyCode.Quote })
    Cmdr:SetPlaceName("CStory-0.7.5")

    plr.Chatted:Connect(function(msg)
        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest:Fire() end
    end)
end
Spawn(cmdrRegister)
