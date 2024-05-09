--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local floor = math.floor

local ITEM_ATTRIBUTES = { RESTORE_BUFF = 0.3 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

BuffEffectsUtil:RestoreMana(char, floor(char:GetAttribute("MaxMana") * ITEM_ATTRIBUTES.RESTORE_BUFF))
