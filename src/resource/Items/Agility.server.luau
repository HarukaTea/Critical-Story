--!nocheck

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 15, DURATION = 10, POWER = 10 }

ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script)

SkillUtil:SpeedBuff(plr, ITEM_ATTRIBUTES.POWER, ITEM_ATTRIBUTES.DURATION)
