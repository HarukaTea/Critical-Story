--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { DURATION = 10, POWER = 2 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:SpeedBuff(char, ITEM_ATTRIBUTES.POWER, ITEM_ATTRIBUTES.DURATION)
