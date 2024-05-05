--!nocheck
--!optimize 2
--!native

local DSS = game:GetService("DataStoreService")
local MS = game:GetService("MessagingService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local DS = DSS:GetDataStore("CS_MILKPANEL")
local SCOPE = "CS_BANLIST_V1"

local time = os.time
local format = string.format

local banList = {}

local function setup()
    local ds = DS:GetAsync(SCOPE)

    if not ds then
        DS:SetAsync(SCOPE, banList)
    else
        banList = ds
    end

    MS:SubscribeAsync("BanRequest", function(message: table)
        local data = message.Data :: table

        if Players:FindFirstChild(data[1]) then
            local cheater = Players[data[1]] :: Player

            cheater:Kick("You've got banned! Reason: "..data[3]..", Duration: "..data[2].." Hours!")
        end
    end)
end
setup()

local function checkIsBanned(plr: Player)
    if not banList[plr.Name] then return end

    local info = banList[plr.Name] :: table
    local timeGap = (time() - info.BannedTime) / 60 / 60

    if timeGap < info.Duration then
        local durationLeft = format("%.1f", tostring(info.Duration - timeGap))

        plr:Kick("You got banned! Reason: "..info.Reason..", unban in "..durationLeft.." hours!")
    else
        banList[plr.Name] = nil
    end
end
Players.PlayerAdded:Connect(checkIsBanned)

local function banRequest(plr: string, duration: number, reason: string)
    banList[plr] = {
        BannedTime = time(),
        Duration = duration,
        Reason = reason
    }
    MS:PublishAsync("BanRequest", { plr, duration, reason })

    DS:SetAsync(SCOPE, banList)
end
Signals.BanRequest:Connect(banRequest)

local function saveList()
    DS:SetAsync(SCOPE, banList)
end
game:BindToClose(saveList)

--// Setups
for _, plr: Player in Players:GetPlayers() do
    if plr then Spawn(checkIsBanned, plr) end
end
