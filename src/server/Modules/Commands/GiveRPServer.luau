--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))
local numberCheck2 = Guard.Check(Guard.Integer)

return function (_, players: table, rp: number)
    local rpPass, _ = numberCheck(rp)
    local rpPass2, rpWant2 = numberCheck2(rp)

    if not rpPass or not rpPass2 then
        return "I guess you typed incorrect RP amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "RP", rpWant2)
    end

    return "RP Added: "..HarukaLib:NumberConvert(rpWant2, "%.1f").."!"
end
