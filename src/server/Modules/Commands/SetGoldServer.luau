--!strict

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (_, plr, gold)
    local goldPass, goldWant = numberCheck(gold)

    if not goldPass then
        return "I guess you typed incorrectly..."
    end

    HarukaLib:Add(plr, "Gold", goldWant)

    return plr.DisplayName.."'s Gold has added "..goldWant
end
