--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 12, DMG_BUFF = 2, DURATION = 6, MANA_REQ = 100 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:AttackBuff(char, ITEM_ATTRIBUTES.DMG_BUFF, ITEM_ATTRIBUTES.DURATION)
