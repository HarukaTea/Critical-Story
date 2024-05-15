--!nocheck
--!optimize 2
--!native

local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local floor = math.floor

local ITEM_ATTRIBUTES = { RESTORE_BUFF = 0.3 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Heal)
BuffEffectsUtil:RestoreMana(char, floor(char:GetAttribute("MaxMana") * ITEM_ATTRIBUTES.RESTORE_BUFF))
