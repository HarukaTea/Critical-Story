--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

return function (_, players: table, rp: number)
    local check = HarukaLib:TypeCheck("MinMax", rp, -99999999, 99999999)
    local check2 = HarukaLib:TypeCheck("Integer", rp)

    if not check or not check2 then
        return "I guess you typed incorrect reputation amount..."
    end

    for _, plr: Player in players do
        HarukaLib:AddAttr(plr, "RP", rp)

        if plr:GetAttribute("RP") < 0 then plr:SetAttribute("RP", 0) end
    end

    return "RP Added: "..HarukaLib:NumberConvert(rp, "%.1f").."!"
end
