--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 8, HEAL_BUFF = 0.35, ATTACK_BUFF = 1.5, DURATION = 5 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:Heal(char, ITEM_ATTRIBUTES.HEAL_BUFF)
BuffEffectsUtil:AttackBuff(char, ITEM_ATTRIBUTES.ATTACK_BUFF, ITEM_ATTRIBUTES.DURATION)
