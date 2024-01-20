--!nocheck

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local ServerUtil = HarukaFrameworkServer.ServerUtil
local SkillUtil = HarukaFrameworkServer.SkillUtil

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 1, BUFF = 0.05 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then
	return
end

SkillUtil:Heal(plr, floor(char.Humanoid.MaxHealth * ITEM_ATTRIBUTES.BUFF))
