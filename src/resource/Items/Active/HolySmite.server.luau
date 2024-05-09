--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local ITEM_ATTRIBUTES = { COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.AnimeExplosion)
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Explosion)
Events.PlayAnimation:Fire(plr, "MagicCastedAnim1")

BuffEffectsUtil:Burn(char, monster, 6)

local explosion = RepS.Package.MagicAssets.HolySmite.Explosion:Clone() :: BasePart
explosion.CFrame = monster.PrimaryPart.CFrame
explosion.Parent = char
Debris:AddItem(explosion, 1)

local holyBeam = RepS.Package.MagicAssets.HolySmite.HolyBeam:Clone() :: BasePart
holyBeam.CFrame = monster.PrimaryPart.CFrame
holyBeam.Parent = char
Debris:AddItem(holyBeam, 1)

Events.ClientTween:Fires({ explosion }, { Size = v3New(254, 254, 254), Transparency = 1 }, "half")
Events.ClientTween:Fires({ holyBeam }, { Size = v3New(), Transparency = 1 }, "onceHalf")

local dmg = char:GetAttribute("Magic") :: number

ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 85, 0))

HarukaLib:Add(monster, "Health", -dmg)
