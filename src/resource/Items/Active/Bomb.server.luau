--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local fromRGB = Color3.fromRGB
local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 12, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
BuffEffectsUtil:MagicVFX(monster)

Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Bomb })
Events.PlayAnimation.Fire(plr, { AnimId = "MagicCastedAnim1" })

local dmg = floor(char:GetAttribute("MinDMG") * 3) :: number

ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 0, 127))

HarukaLib:AddAttr(monster, "Health", -dmg)
