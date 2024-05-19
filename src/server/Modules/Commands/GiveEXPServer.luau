--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))
local numberCheck2 = Guard.Check(Guard.Integer)

return function (_, players: table, exp: number)
    local expPass, _ = numberCheck(exp)
    local expPass2, expWant2 = numberCheck2(exp)

    if not expPass or not expPass2 then
        return "I guess you typed incorrect exp amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "EXP", expWant2)
    end

    return "EXP Added: "..HarukaLib:NumberConvert(expWant2, "%.1f").."!"
end
