--!nocheck

local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local ITEM_ATTRIBUTES = { CD = 12 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Heal })

BuffEffectsUtil:PurifyBuff(char)
