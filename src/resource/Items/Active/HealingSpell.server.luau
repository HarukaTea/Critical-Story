--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 15, COMBAT_REQ = true, HEAL_BUFF = 0.5 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
for _, player: Player in Players:GetPlayers() do
    if player == plr then continue end

    pcall(function()
        local distance = player:DistanceFromCharacter(char.PrimaryPart.Position)

        if distance <= 66 and distance > 0 and player.Character:GetAttribute("InCombat") then
            BuffEffectsUtil:Heal(player.Character, ITEM_ATTRIBUTES.HEAL_BUFF)
        end
    end)
end
