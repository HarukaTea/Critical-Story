--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Guard = require(RepS.Modules.Packages.Guard)
local Signals = require(SSS.Modules.Data.ServerSignals)

local stringCheck = Guard.Check(Guard.String)
local numberCheck = Guard.Check(Guard.NumberMinMax(0, 24 * 365 + 1))

return function (_, plr: string, duration: number, reason: string)
    local plrCheck, plrWant = stringCheck(plr)
    local durationPass, durationWant = numberCheck(duration)

    if not plrCheck then
        return "I guess you typed incorrect player name..."
    end
    if not durationPass then
        return "I guess you typed incorrect duration..."
    end

    Signals.BanRequest:Fire(plrWant, durationWant, reason)

    return plrWant.." got banned with "..durationWant.." seconds!"
end
