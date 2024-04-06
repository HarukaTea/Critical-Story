--!strict
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
    if item == "AbsorptionCrystal" then
        HarukaLib:Add(char, "ShieldBuff", 2)

    elseif item == "AdventurersKit" then
        char:SetAttribute("CanSpawnMultiOrb", true)

    elseif item == "AncientHammer" then
        HarukaLib:Add(char, "ShieldBuff", 120)
        HarukaLib:Add(char, "MaxDMGBuff", 40)

    elseif item == "AquaLapis" then
        HarukaLib:Add(char, "ManaBuff", 600)
        HarukaLib:Add(char, "RestoreBuff", 30)

    elseif item == "ArcaneSpellbook" then
        HarukaLib:Add(char, "MagicBuff", 125)

    elseif item == "BlackWolfNecklace" then
        HarukaLib:Add(char, "MaxDMGBuff", 200)
        HarukaLib:Add(char, "SpeedBuff", 10)

    elseif item == "BurningTorch" then
        char:SetAttribute("CanLight", true)

        RepS.Resources.Items.BurningTorch:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "CampfireWood" then
        HarukaLib:Add(char, "HealBuff", 30)
        HarukaLib:Add(char, "HealthBuff", 20)

    elseif item == "CopperSword" then
        HarukaLib:Add(char, "MaxDMGBuff", 15)

    elseif item == "EnchantedBlade" then
        HarukaLib:Add(char, "MaxDMGBuff", 70)
        HarukaLib:Add(char, "MinDMGBuff", 30)
        HarukaLib:Add(char, "MagicBuff", 60)

    elseif item == "EverfrostSeeds" then
        char:SetAttribute("CanEnterStronghold", true)

    elseif item == "FireStaff" then
        char.CharStats.ExtraOrbs:SetAttribute("FireStaffOrb", true)

    elseif item == "FlameSword" then
        HarukaLib:Add(char, "BurnChance", 30)
        HarukaLib:Add(char, "MaxDMGBuff", 100)

    elseif item == "FoxSpirit" then
        HarukaLib:Add(char, "SpeedBuff", 30)
        HarukaLib:Add(char, "MagicBuff", 50)

        RepS.Resources.Items.FoxSpirit:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "HotPotato" then
        HarukaLib:Add(char, "SpeedBuff", 10)
        HarukaLib:Add(char, "BurnChance", 10)

    elseif item == "HuntingDagger" then
        HarukaLib:Add(char, "MinDMGBuff", 5)

    elseif item == "KitsuneGloves" then
        HarukaLib:Add(char, "MagicBuff", 50)
        HarukaLib:Add(char, "MaxDMGBuff", 50)
        HarukaLib:Add(char, "CriChance", 5)

    elseif item == "MagicWand" then
        HarukaLib:Add(char, "MagicBuff", 125)

    elseif item == "MagicianHat" then
        HarukaLib:Add(char, "MagicBuff", 125)

    elseif item == "ManaCrystal" then
        HarukaLib:Add(char, "MagicBuff", 20)

        RepS.Resources.Items.ManaCrystal:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "MountainKingClown" then
        HarukaLib:Add(char, "MaxDMGBuff", 125)

    elseif item == "MilkPillow" then
        HarukaLib:Add(char, "MaxDMGBuff", 9999)

    elseif item == "NorthernHalberd" then
        HarukaLib:Add(char, "MaxDMGBuff", 125)
        HarukaLib:Add(char, "MinDMGBuff", 100)

    elseif item == "NorthernerAxe" then
        HarukaLib:Add(char, "MaxDMGBuff", 70)

    elseif item == "RabbitFoot" then
        HarukaLib:Add(char, "SpeedBuff", 5)
        HarukaLib:Add(char, "JumpBuff", 40)

    elseif item == "RegenerationGem" then
        RepS.Resources.Items.RegenerationGem:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "StalkerCape" then
        HarukaLib:Add(char, "DodgeChance", 15)

    elseif item == "TundraGear" then
        HarukaLib:Add(char, "SpeedBuff", 10)

    elseif item == "MiningPickaxe" then
        HarukaLib:Add(char, "MaxDMGBuff", 5)
        char:SetAttribute("CanMine", true)

    elseif item == "TravellerBoots" then
        HarukaLib:Add(char, "SpeedBuff", 10)
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

        elseif find(attribute, "Chance") then
            char:SetAttribute(attribute, 0)

            if attribute == "CriChance" then char:SetAttribute(attribute, 1) end
        end
    end
    for attribute, _ in char.CharStats.ExtraOrbs:GetAttributes() do
        char:SetAttribute(attribute, nil)
    end
    char.CharStats.ExtraOrbs:ClearAllChildren()

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
