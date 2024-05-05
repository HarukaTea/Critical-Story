--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (_, players: table, gold: number)
    local goldPass, goldWant = numberCheck(gold)

    if not goldPass then
        return "I guess you typed incorrect gold amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "Gold", goldWant)
    end

    return "Gold Added: "..HarukaLib:NumberConvert(goldWant, "%.1f").."!"
end
