--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local PassiveUtil = {}

local find, sub = string.find, string.sub

--[[
    Equip a new passive, and apply its buffs
]]
function PassiveUtil:EquipPassive(item: string, char: Model)
    if item == "TravellerBoots" then
        HarukaLib:Add(char, "SpeedBuff", 5)

    elseif item == "BurningTorch" then
        RepS.Resources.Items.BurningTorch:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "CampfireWood" then
        HarukaLib:Add(char, "HealBuff", 30)

    elseif item == "HuntingDagger" then
        HarukaLib:Add(char, "MinDMGBuff", 5)

    elseif item == "MiningPickaxe" then
        char:SetAttribute("CanMine", true)

    elseif item == "CopperSword" then
        HarukaLib:Add(char, "MaxDMGBuff", 15)

    elseif item == "AncientHammer" then
        HarukaLib:Add(char, "MaxDMGBuff", 20)
        HarukaLib:Add(char, "ShieldBuff", 20)

    elseif item == "ManaCrystal" then
        RepS.Resources.Items.ManaCrystal:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "RabbitFoot" then
        HarukaLib:Add(char, "JumpBuff", 20)

    elseif item == "ArcaneSpellbook" then
        HarukaLib:Add(char, "MagicBuff", 120)

        --// TODO: Be the member of Faction

    elseif item == "MagicianHat" then
        HarukaLib:Add(char, "MagicBuff", 120)

        --//

    elseif item == "EnchantedBlade" then
        HarukaLib:Add(char, "MaxDMGBuff", 120)
        HarukaLib:Add(char, "MagicBuff", 50)

    elseif item == "StalkerCape" then
        HarukaLib:Add(char, "DodgeChance", 15)
        HarukaLib:Add(char, "HealthBuff", 100)

    elseif item == "RegenerationGem" then
        RepS.Resources.Items.RegenerationGem:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "BlackwolfNecklace" then
        HarukaLib:Add(char, "MaxDMGBuff", 150)
        HarukaLib:Add(char, "SpeedBuff", 10)

    elseif item == "FlameSword" then
        HarukaLib:Add(char, "BurnChance", 15)
        HarukaLib:Add(char, "MaxDMGBuff", 100)

    elseif item == "KitsuneGloves" then
        HarukaLib:Add(char, "MagicBuff", 50)
        HarukaLib:Add(char, "MaxDMGBuff", 50)

    elseif item == "AquaLapis" then
        HarukaLib:Add(char, "CriChance", 10)

    elseif item == "EverfrostSeed" then
        char:SetAttribute("CanEnterStronghold", true)

    elseif item == "HotPotato" then
        HarukaLib:Add(char, "SpeedBuff", 15)

    elseif item == "NorthernerAxe" then
        HarukaLib:Add(char, "MaxDMGBuff", 70)
        char:SetAttribute("CanCutTrees", true)

    elseif item == "TundraGear" then
        char:SetAttribute("CanImmenseCold", true)

    elseif item == "FoxSpirit" then
        HarukaLib:Add(char, "MagicBuff", 50)
        HarukaLib:Add(char, "SpeedBuff", 15)

        RepS.Resources.Items.FoxSpirit:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "NorthernHalberd" then
        HarukaLib:Add(char, "MaxDMGBuff", 80)

    elseif item == "AbsorptionCrystal" then
        HarukaLib:Add(char, "ShieldBuff", 50)
        HarukaLib:Add(char, "TPRestoreBuff", 10)

    elseif item == "FireStaff" then
        char.CharStats.ExtraOrbs:SetAttribute("FireStaffOrb", true)

    elseif item == "MountainKingCrown" then
        HarukaLib:Add(char, "HealthBuff", 300)
        HarukaLib:Add(char, "ShieldBuff", 60)
        HarukaLib:Add(char, "MaxDMGBuff", 100)
    end

    char.CharStats.Items:SetAttribute(item.."_PASSIVE", true)
end

--[[
    Unequip a passive by clear all passive, and re-equip the rest
]]
function PassiveUtil:ClearAllPassives(char: Model)
    for attribute: string, _ in char:GetAttributes() do
        if find(attribute, "Buff") then
            char:SetAttribute(attribute, 0)

        elseif find(attribute, "Can") then
            char:SetAttribute(attribute, nil)

        elseif find(attribute, "Chance") then
            char:SetAttribute(attribute, 0)

            if attribute == "CriChance" then char:SetAttribute(attribute, 1) end
        end
    end
    for attribute: string, _ in char.CharStats.ExtraOrbs:GetAttributes() do
        char:SetAttribute(attribute, nil)
    end
    char.CharStats.ExtraOrbs:ClearAllChildren()

    --- re-equip
    for attibute: string, value: any in char.CharStats.Items:GetAttributes() do
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
