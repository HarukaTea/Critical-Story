--!nocheck

local SSS = game:GetService("ServerScriptService")

local HarukaFrameworkServer = require(SSS.Modules.HarukaFrameworkServer)

local HarukaLib = HarukaFrameworkServer.HarukaLib
local Guard = HarukaFrameworkServer.Guard

local numberCheck = Guard.Check(Guard.NumberMinMax(1, 99999999))

return function (_, plr, gold)
    local goldPass, goldWant = numberCheck(gold)

    if not goldPass then
        return "I guess you typed incorrectly..."
    end

    HarukaLib:Add(plr, "Gold", goldWant)

    return plr.DisplayName.."'s Gold has added "..goldWant
end
