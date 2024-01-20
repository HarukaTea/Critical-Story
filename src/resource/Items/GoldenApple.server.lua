--!nocheck

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local ServerUtil = HarukaFrameworkServer.ServerUtil
local SkillUtil = HarukaFrameworkServer.SkillUtil

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 7, HEAL_BUFF = 0.15, ATTACK_BUFF = 1.5, DURATION = 5 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then
	return
end

SkillUtil:Heal(plr, floor(char.Humanoid.MaxHealth * ITEM_ATTRIBUTES.HEAL_BUFF))
SkillUtil:AttackBuff(plr, ITEM_ATTRIBUTES.ATTACK_BUFF, ITEM_ATTRIBUTES.DURATION)
