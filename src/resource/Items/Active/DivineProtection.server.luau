--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 18, DEFENSE_BUFF = 99, DURATION = 6 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)
BuffEffectsUtil:DefenseBuff(char, ITEM_ATTRIBUTES.DEFENSE_BUFF, ITEM_ATTRIBUTES.DURATION)
