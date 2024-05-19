--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))
local numberCheck2 = Guard.Check(Guard.Integer)

return function (_, players: table, gold: number)
    local goldPass, _ = numberCheck(gold)
    local goldPass2, goldWant2 = numberCheck2(gold)

    if not goldPass or not goldPass2 then
        return "I guess you typed incorrect gold amount..."
    end

    for _, plr: Player in players do
        HarukaLib:Add(plr, "Gold", goldWant2)
    end

    return "Gold Added: "..HarukaLib:NumberConvert(goldWant2, "%.1f").."!"
end
