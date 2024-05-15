--!nocheck
--!optimize 2
--!native

local MS = game:GetService("MessagingService")
local RepS = game:GetService("ReplicatedStorage")

local Guard = require(RepS.Modules.Packages.Guard)

local stringCheck = Guard.Check(Guard.String)
local numberCheck = Guard.Check(Guard.NumberMinMax(0, 24 * 365 + 1))

return function (_, plrName: string, duration: number, reason: string)
    local plrCheck, plrWant = stringCheck(plrName)
    local durationPass, durationWant = numberCheck(duration)

    if not plrCheck then
        return "I guess you typed incorrect player name..."
    end
    if not durationPass then
        return "I guess you typed incorrect duration..."
    end

    MS:PublishAsync("BanRequest", { plrName, duration, reason })

    return plrWant.." got banned with "..durationWant.." seconds!"
end
