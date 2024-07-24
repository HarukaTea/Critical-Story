--!nocheck

local Debris = game:GetService("Debris")
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
local v3New = Vector3.new

local ITEM_ATTRIBUTES = { CD = 12, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.AnimeExplosion })
Events.PlayAnimation.Fire(plr, { AnimId = "MagicCastedAnim1" })
Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Explosion })

BuffEffectsUtil:Burn(char, monster, 6)

local explosion = RepS.Package.MagicAssets.HolySmite.Explosion:Clone() :: BasePart
explosion.CFrame = monster.PrimaryPart.CFrame
explosion.Parent = workspace
Debris:AddItem(explosion, 1)

local holyBeam = RepS.Package.MagicAssets.HolySmite.HolyBeam:Clone() :: BasePart
holyBeam.CFrame = monster.PrimaryPart.CFrame
holyBeam.Parent = workspace
Debris:AddItem(holyBeam, 1)

Events.ClientTween.FireAll({ Objs = { explosion }, Goal = { Size = v3New(254, 254, 254), Transparency = 1 }, TweenInfo = "half" })
Events.ClientTween.FireAll({ Objs = { holyBeam }, Goal = { Size = v3New(), Transparency = 1 }, TweenInfo = "onceHalf" })

local dmg = char:GetAttribute("Magic") :: number

ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 85, 0))

HarukaLib:AddAttr(monster, "Health", -dmg)
