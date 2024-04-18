--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 10, ATTACK_BUFF = 1.5, DURATION = 5 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

SkillUtil:AttackBuff(plr, ITEM_ATTRIBUTES.ATTACK_BUFF, ITEM_ATTRIBUTES.DURATION)
