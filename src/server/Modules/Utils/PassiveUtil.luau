--!nocheck

local HarukaLib = require(game:GetService("ReplicatedStorage").Modules.Packages.HarukaLib)

local PassiveUtil = {}

local find, sub = string.find, string.sub

--[[
    Equip a new passive, and apply its buffs
]]
function PassiveUtil:EquipPassive(item: string, char: Model)
    if item == "HuntingDagger" then
        HarukaLib:Add(char, "DamageBuff", 5)

    elseif item == "MiningPickaxe" then
        HarukaLib:Add(char, "DamageBuff", 5)
        char:SetAttribute("CanMine", true)

    elseif item == "TravellerBoots" then
        HarukaLib:Add(char, "SpeedBuff", 6)
    end

    char.CharStats.Items:SetAttribute(item.."_PASSIVE", true)
end

--[[
    Unequip a passive by clear all passive, and re-equip the rest
]]
function PassiveUtil:ClearAllPassives(char: Model)
    for attribute, _ in char:GetAttributes() do
        if find(attribute, "Buff") then
            char:SetAttribute(attribute, 0)

        elseif find(attribute, "Can") then
            char:SetAttribute(attribute, nil)
        end
    end

    --- re-equip
    for attibute, value in char.CharStats.Items:GetAttributes() do
        if find(attibute, "_PASSIVE") then
            if value == false then
                char.CharStats.Items:SetAttribute(attibute, nil)
                continue
            end

            local start = find(attibute, "_PASSIVE")
            local realItemName = sub(attibute, 1, start - 1)
            PassiveUtil:EquipPassive(realItemName, char)
        end
    end
end

return PassiveUtil
