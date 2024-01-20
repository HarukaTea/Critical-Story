--!nocheck

local SSS = game:GetService("ServerScriptService")

local HarukaFrameworkServer = require(SSS.Modules.HarukaFrameworkServer)

local HarukaLib = HarukaFrameworkServer.HarukaLib
local Guard = HarukaFrameworkServer.Guard

local numberCheck = Guard.Check(Guard.NumberMinMax(1, 99999999))

return function (_, plr, rep)
    local repPass, repWant = numberCheck(rep)

    if not repPass then
        return "I guess you typed incorrectly..."
    end

    HarukaLib:Add(plr, "RP", repWant)

    return plr.DisplayName.."'s RP has added "..repWant
end
