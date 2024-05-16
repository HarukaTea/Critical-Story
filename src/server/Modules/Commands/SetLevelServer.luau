--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 950))

return function (_, players: table, level: number)
    local levelPass, levelWant = numberCheck(level)

    if not levelPass then
        return "I guess you typed incorrect level..."
    end

    if levelWant > 150 then
        return "The level cap is 150 bro!"
    else
        for _, plr: Player in players do
            plr:SetAttribute("EXP", 0)
            plr:SetAttribute("DMGPoints", 0)
            plr:SetAttribute("MagicPoints", 0)
            plr:SetAttribute("HealthPoints", 0)
            plr:SetAttribute("ShieldPoints", 0)
            plr:SetAttribute("ManaPoints", 0)
            plr:SetAttribute("Levels", levelWant)
            plr:SetAttribute("LvPoints", (levelWant - 1) * 2)
        end

        return "Level has set to "..levelWant.."!"
    end
end
