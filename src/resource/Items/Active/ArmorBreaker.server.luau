--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local fromRGB = Color3.fromRGB
local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 6, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
BuffEffectsUtil:MagicVFX(monster)
Events.PlayAnimation:Fire(plr, "MagicCastedAnim1")
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

local dmg = floor(char:GetAttribute("MaxDMG")) :: number

ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 0, 127))

HarukaLib:Add(monster, "Health", -dmg)