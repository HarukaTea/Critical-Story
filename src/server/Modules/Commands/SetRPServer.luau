--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 99999999))

return function (_, plr, rep)
    local repPass, repWant = numberCheck(rep)

    if not repPass then
        return "I guess you typed incorrectly..."
    end

    HarukaLib:Add(plr, "RP", repWant)

    return plr.DisplayName.."'s RP has added "..repWant
end
