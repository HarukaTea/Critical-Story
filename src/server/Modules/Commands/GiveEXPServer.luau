--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (_, players: table, exp: number)
    local expPass, expWant = numberCheck(exp)

    if not expPass then
        return "I guess you typed incorrect exp amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "EXP", expWant)
    end

    return "EXP Added: "..HarukaLib:NumberConvert(expWant, "%.1f").."!"
end
