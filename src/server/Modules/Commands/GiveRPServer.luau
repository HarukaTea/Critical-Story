--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (_, players: table, rp: number)
    local rpPass, rpWant = numberCheck(rp)

    if not rpPass then
        return "I guess you typed incorrect RP amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "RP", rpWant)
    end

    return "RP Added: "..HarukaLib:NumberConvert(rpWant, "%.1f").."!"
end
