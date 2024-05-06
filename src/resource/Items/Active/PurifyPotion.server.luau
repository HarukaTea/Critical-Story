--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { COMBAT_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:PurifyBuff(char)
