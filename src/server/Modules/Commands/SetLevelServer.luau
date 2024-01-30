--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Guard = require(RepS.Modules.Packages.Guard)

local numberCheck = Guard.Check(Guard.NumberMinMax(0, 950))

return function (_, plr, level)
    local levelPass, levelWant = numberCheck(level)

    if not levelPass then
        return "I guess you typed incorrectly..."
    end

    if levelWant > 125 then
        return "The level cap is 125 bro!"
    else
        plr:SetAttribute("DmgPoints", 0)
		plr:SetAttribute("MagicPoints", 0)
		plr:SetAttribute("ManaPoints", 0)
		plr:SetAttribute("HealthPoints", 0)
		plr:SetAttribute("ShieldPoints", 0)
        plr:SetAttribute("Levels", levelWant)
        plr:SetAttribute("LvPoints", (levelWant - 1) * 2)

        return plr.DisplayName.."'s level has set to "..levelWant
    end
end
