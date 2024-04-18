--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 1, BUFF = 0.1 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

SkillUtil:Heal(plr, ITEM_ATTRIBUTES.BUFF)
