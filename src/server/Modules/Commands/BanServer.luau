--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Guard = require(RepS.Modules.Packages.Guard)
local Signals = require(SSS.Modules.Data.ServerSignals)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 24 * 365 + 1))

return function (_, plr: Player, duration: number, reason: string)
    local durationPass, durationWant = numberCheck(duration)

    if not durationPass then
        return "I guess you typed incorrect duration..."
    end

    Signals.BanRequest:Fire(plr, durationWant, reason)

    return plr.Name.." got banned with "..durationWant.." seconds!"
end
