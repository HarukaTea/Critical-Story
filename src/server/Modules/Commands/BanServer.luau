--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

return function (_, player: string, duration: number, reason: string)
    local check = pcall(function()
        assert(type(player) == "string")
    end)
    if not check then return "I guess you typed incorrect player name..." end

    local check2 = HarukaLib:TypeCheck("MinMax", duration, 0, 24 * 365 * 60 * 60 + 1)
    if not check2 then return "I guess you typed incorrect duration..." end

    local check3 = HarukaLib:TypeCheck("Integer", duration)
    if not check3 then return "I guess you typed incorrect duration..." end

    local playerId: number
    local check4 = pcall(function()
        playerId = Players:GetUserIdFromNameAsync(player)
    end)
    if not check4 then return "Player not found!" end

    local config = {
        UserIds = { playerId },
        Duration = duration,
        DisplayReason = reason,
        PrivateReason = reason,
        ExcludeAltAccounts = false,
        ApplyToUniverse = true
    }

    local ok, err = pcall(function()
        Players:BanAsync(config)
    end)
    if not ok then warn(err) end

    return player.." got banned with "..duration.." seconds! Reason: "..reason
end
