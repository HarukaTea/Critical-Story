--!nocheck

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 1, BUFF = 0.05 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then
	return
end

SkillUtil:Heal(plr, floor(char.Humanoid.MaxHealth * ITEM_ATTRIBUTES.BUFF))
