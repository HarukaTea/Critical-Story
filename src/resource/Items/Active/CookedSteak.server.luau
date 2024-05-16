--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 8, DURATION = 6, ATTACK_POWER = 1.2, HEAL_BUFF = 0.1 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:Heal(char, ITEM_ATTRIBUTES.HEAL_BUFF)
BuffEffectsUtil:AttackBuff(char, ITEM_ATTRIBUTES.ATTACK_POWER, ITEM_ATTRIBUTES.DURATION)
