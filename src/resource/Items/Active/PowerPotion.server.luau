--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { ATTACK_BUFF = 1.5, TURN = 1, COMBAT_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:AttackBuff(char, ITEM_ATTRIBUTES.ATTACK_BUFF, ITEM_ATTRIBUTES.TURN)
