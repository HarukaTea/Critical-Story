--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

return function (_, players: table, level: number)
    local check = HarukaLib:TypeCheck("MinMax", level, 0, 9999)
    local check2 = HarukaLib:TypeCheck("Integer", level)

    if not check or not check2 then
        return "I guess you typed incorrect level..."
    end

    if level > Formula.LevelCap then
        return "The level cap is 1100 bro!"
    else
        for _, plr: Player in players do
            plr:SetAttribute("EXP", 0)
            plr:SetAttribute("DMGPoints", 0)
            plr:SetAttribute("MagicPoints", 0)
            plr:SetAttribute("HealthPoints", 0)
            plr:SetAttribute("ManaPoints", 0)
            plr:SetAttribute("Levels", level)
            plr:SetAttribute("LvPoints", (level - 1) * Formula.LevelPerPoint)
        end

        return "Level has set to "..level.."!"
    end
end
