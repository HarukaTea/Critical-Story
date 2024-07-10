--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

return function (_, players: table, gold: number)
    local check = HarukaLib:TypeCheck("MinMax", gold, -99999999, 99999999)
    local check2 = HarukaLib:TypeCheck("Integer", gold)

    if not check or not check2 then
        return "I guess you typed incorrect gold amount..."
    end

    for _, plr: Player in players do
        HarukaLib:AddAttr(plr, "Gold", gold)

        if plr:GetAttribute("Gold") < 0 then plr:SetAttribute("Gold", 0) end
    end

    return "Gold Added: "..HarukaLib:NumberConvert(gold, "%.1f").."!"
end
