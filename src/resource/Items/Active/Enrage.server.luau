--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 12, DMG_BUFF = 2, DURATION = 6 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:AttackBuff(char, ITEM_ATTRIBUTES.DMG_BUFF, ITEM_ATTRIBUTES.DURATION)
