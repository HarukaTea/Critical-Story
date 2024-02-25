--!nocheck

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 10, DURATION = 5, ATTACK_POWER = 1.5, HEAL_BUFF = 0.25 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

SkillUtil:Heal(plr, ITEM_ATTRIBUTES.HEAL_BUFF)
SkillUtil:AttackBuff(plr, ITEM_ATTRIBUTES.ATTACK_POWER, ITEM_ATTRIBUTES.DURATION)
