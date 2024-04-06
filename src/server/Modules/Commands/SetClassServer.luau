--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Guard = require(RepS.Modules.Packages.Guard)

local stringCheck = Guard.Check(Guard.String)

return function (_, plr, class)
    local classPass, classWant = stringCheck(class)

    if not classPass then
        return "I guess you typed incorrectly..."
    end
    if plr:GetAttribute("Class") == classWant then
        return "Isn't your class already "..classWant.." right now???"
    end

    plr:SetAttribute("Class", classWant)

    return plr.DisplayName.."'s Class has set to "..classWant
end
