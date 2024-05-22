--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 950))
local numberCheck2 = Guard.Check(Guard.Integer)

return function (_, players: table, level: number)
    local levelPass, _ = numberCheck(level)
    local levelPass2, levelWant2 = numberCheck2(level)

    if not levelPass or not levelPass2 then
        return "I guess you typed incorrect level..."
    end

    if levelWant2 > 150 then
        return "The level cap is 150 bro!"
    else
        for _, plr: Player in players do
            plr:SetAttribute("EXP", 0)
            plr:SetAttribute("DmgPoints", 0)
            plr:SetAttribute("MagicPoints", 0)
            plr:SetAttribute("HealthPoints", 0)
            plr:SetAttribute("ShieldPoints", 0)
            plr:SetAttribute("ManaPoints", 0)
            plr:SetAttribute("Levels", levelWant2)
            plr:SetAttribute("LvPoints", (levelWant2 - 1) * 2)
        end

        return "Level has set to "..levelWant2.."!"
    end
end
