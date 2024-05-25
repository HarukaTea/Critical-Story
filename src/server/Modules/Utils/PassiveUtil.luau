--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local PassiveUtil = {}

local find, sub = string.find, string.sub

--[[
    Equip a new passive, and apply its buffs
]]
function PassiveUtil:EquipPassive(item: string, char: Model)
    if item == "TravellerBoots" then
        HarukaLib:AddAttr(char, "SpeedBuff", 8)

    elseif item == "BurningTorch" then
        HarukaLib:AddAttr(char, "SpeedBuff", 4)

        SS.Resources.Items.Passive.BurningTorch:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "CampfireWood" then
        HarukaLib:AddAttr(char, "HealBuff", 30)

    elseif item == "HuntingDagger" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 5)

    elseif item == "MiningPickaxe" then
        char:SetAttribute("CanMine", true)

    elseif item == "CopperSword" then
        HarukaLib:AddAttr(char, "MaxDMGBuff", 15)

    elseif item == "AncientHammer" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 20)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 40)
        HarukaLib:AddAttr(char, "ShieldBuff", 20)

    elseif item == "ManaCrystal" then
        HarukaLib:AddAttr(char, "ManaBuff", 100)

        SS.Resources.Items.Passive.ManaCrystal:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "RabbitFoot" then
        HarukaLib:AddAttr(char, "JumpBuff", 20)

    elseif item == "ArcaneSpellbook" then
        HarukaLib:AddAttr(char, "MagicBuff", 120)
        HarukaLib:AddAttr(char, "ManaBuff", 100)

        --// TODO: Be the member of Faction

    elseif item == "MagicianHat" then
        HarukaLib:AddAttr(char, "HealthBuff", 300)
        HarukaLib:AddAttr(char, "MagicBuff", 120)

        --// TODO: be the member of Faction

    elseif item == "EnchantedBlade" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 25)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 100)
        HarukaLib:AddAttr(char, "MagicBuff", 50)

    elseif item == "StalkerCape" then
        HarukaLib:AddAttr(char, "DodgeChance", 15)
        HarukaLib:AddAttr(char, "SpeedBuff", 5)
        HarukaLib:AddAttr(char, "HealthBuff", 100)

    elseif item == "RegenerationGem" then
        HarukaLib:AddAttr(char, "HealthBuff", 150)

        SS.Resources.Items.Passive.RegenerationGem:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "BlackwolfNecklace" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 75)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 150)
        HarukaLib:AddAttr(char, "SpeedBuff", 10)

    elseif item == "FlameSword" then
        HarukaLib:AddAttr(char, "BurnChance", 10)
        HarukaLib:AddAttr(char, "MagicBuff", 25)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 100)

    elseif item == "KitsuneGloves" then
        HarukaLib:AddAttr(char, "MagicBuff", 50)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 50)

    elseif item == "AquaLapis" then
        HarukaLib:AddAttr(char, "MagicBuff", 30)
        HarukaLib:AddAttr(char, "ManaBuff", 150)

    elseif item == "EverfrostSeed" then
        char:SetAttribute("CanEnterStronghold", true)

    elseif item == "HotPotato" then
        HarukaLib:AddAttr(char, "BurnChance", 10)
        HarukaLib:AddAttr(char, "SpeedBuff", 15)

    elseif item == "NorthernerAxe" then
        HarukaLib:AddAttr(char, "MaxDMGBuff", 70)
        char:SetAttribute("CanCutTrees", true)

    elseif item == "TundraGear" then
        char:SetAttribute("CanImmenseCold", true)

    elseif item == "FoxSpirit" then
        HarukaLib:AddAttr(char, "MagicBuff", 50)
        HarukaLib:AddAttr(char, "SpeedBuff", 15)

        SS.Resources.Items.Passive.FoxSpirit:Clone().Parent = char.CharStats.ExtraOrbs

    elseif item == "NorthernHalberd" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 40)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 80)

    elseif item == "AbsorptionCrystal" then
        HarukaLib:AddAttr(char, "ShieldBuff", 50)
        HarukaLib:AddAttr(char, "ManaBuff", 50)
        HarukaLib:AddAttr(char, "RestoreBuff", 10)

    elseif item == "FireStaff" then
        char.CharStats.ExtraOrbs:SetAttribute("FireStaffOrb", true)

    elseif item == "MountainKingCrown" then
        HarukaLib:AddAttr(char, "HealthBuff", 300)
        HarukaLib:AddAttr(char, "ShieldBuff", 60)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 100)

    elseif item == "Devilsknife" then
        HarukaLib:AddAttr(char, "PoisonChance", 30)

    elseif item == "SharpenerRock" then
        HarukaLib:AddAttr(char, "CriChance", 10)

    elseif item == "AdventurersKit" then
        char:SetAttribute("CanSpawnMultiOrb", true)
        HarukaLib:AddAttr(char, "HealBuff", 5)
        HarukaLib:AddAttr(char, "RestoreBuff", 5)

    elseif item == "ClimbingGear" then
        char:SetAttribute("CanClimb", true)

    elseif item == "CrimsonSlimeFang" then
        HarukaLib:AddAttr(char, "MinDMGBuff", 50)
        HarukaLib:AddAttr(char, "MaxDMGBuff", 100)
        HarukaLib:AddAttr(char, "JumpBuff", 5)
        HarukaLib:AddAttr(char, "CriChance", 10)
    end

    char.CharStats.Items:SetAttribute(item.."_PASSIVE", true)
end

--[[
    Unequip a passive, and remove its buffs
]]
function PassiveUtil:UnequipPassive(char: Model, item: string)
    char.CharStats.Items:SetAttribute(item.."_PASSIVE", false)

    PassiveUtil:ClearAllPassives(char)
end

--[[
    Unequip a passive by clear all passive, and re-equip the rest
]]
function PassiveUtil:ClearAllPassives(char: Model)
    for attribute: string, _ in char:GetAttributes() do
        if find(attribute, "Buff") then
            char:SetAttribute(attribute, 0)

            if attribute == "RestoreBuff" or attribute == "HealBuff" then char:SetAttribute(attribute, 10) end

        elseif find(attribute, "Can") then
            char:SetAttribute(attribute, nil)

        elseif find(attribute, "Chance") then
            char:SetAttribute(attribute, 0)

            if attribute == "CriChance" then char:SetAttribute(attribute, 1) end
        end
    end

    char.CharStats.ExtraOrbs:ClearAllChildren()
    HarukaLib:ClearAllAttributes(char.CharStats.ExtraOrbs)

    local light = char.PrimaryPart:FindFirstChildOfClass("PointLight")
    if light then light:Destroy() end

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
