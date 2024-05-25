--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

return function (_, players: table, exp: number)
    local check = HarukaLib:TypeCheck("MinMax", exp, 0, 99999999)
    local check2 = HarukaLib:TypeCheck("Integer", exp)

    if not check or not check2 then
        return "I guess you typed incorrect exp amount..."
    end

    for _, plr: Player in players do
        HarukaLib:AddAttr(plr, "EXP", exp)
    end

    return "EXP Added: "..HarukaLib:NumberConvert(exp, "%.1f").."!"
end
