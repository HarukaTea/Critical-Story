--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Events = require(RepS.Modules.Data.Events)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(RepS.Modules.Data.Signals)
local RankBook = require(RepS.Modules.Data.RankBook)

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
    Cmdr:SetPlaceName("CStory-0.9")

    Signals.PlayerChatted:Connect(function(msg: string, sender: Player)
        if sender ~= plr then return end

        if msg == "!cmds" then Cmdr:Show() end
        if msg == "!rejoin" then Events.RejoinRequest.Fire({}) end
    end)
end
Spawn(cmdrRegister)


local function chatRegister()
    TextChatService.OnIncomingMessage = function(message: TextChatMessage)
        local properties = Instance.new("TextChatMessageProperties")

        --- TextChatAddon
        if message.TextSource then
            --// Player message
            local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
            if not sender:IsDescendantOf(Players) then return properties end

            Signals.PlayerChatted:Fire(message.Text, sender)
            properties.PrefixText = string.format("%s", message.PrefixText)

            if sender:GetAttribute("Role") then
                local role = sender:GetAttribute("Role") :: string
                local roleInfo: table?

                if role == "Alpha Tester" then
                    roleInfo = {
                        ChatRole = "Alpha",
                        Color = "#70a1ff"
                    }
                end
                for _, roleinfo: table in RankBook.RankRoleInfo do
                    if roleinfo.Role == role then roleInfo = roleinfo break end
                end
                for _, roleinfo: table in RankBook.CustomRoleInfo do
                    if roleinfo.Role == role then roleInfo = roleinfo break end
                end

                properties.PrefixText = string.format(
                    "<font color='#%s'><b>[%s]</b></font> %s",
                    roleInfo.Color,
                    string.upper(roleInfo.ChatRole),
                    properties.PrefixText)
            end
        end

        return properties
    end
end
Spawn(chatRegister)


local function disableDefaultFreecam()
    repeat wait() until plr:FindFirstChildOfClass("PlayerGui"):WaitForChild("Freecam", 999)

    plr:FindFirstChildOfClass("PlayerGui").Freecam:Destroy()
end
Spawn(disableDefaultFreecam)
