--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local fromRGB = Color3.fromRGB
local instanceNew = Instance.new
local cfNew = CFrame.new
local v3New = Vector3.new
local random = math.random
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new

local ITEM_ATTRIBUTES = { CD = 10, COMBAT_REQ = true, MONSTER_REQ = true, HEAL_BUFF = 0.2 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.PlayAnimation:Fire(plr, "MagicCastedAnim1")

BuffEffectsUtil:Heal(char, ITEM_ATTRIBUTES.HEAL_BUFF)

local lantern = RepS.Package.MagicAssets.GhostlyLantern.Lantern:Clone() :: MeshPart
lantern.CFrame = char.Torso.CFrame * cfNew(0,0,-4)
lantern.Parent = workspace
Debris:AddItem(lantern, 3)

Events.ClientTween:Fires({ lantern }, { Transparency = 0 }, "twiceHalfOne")
Spawn(function()
	wait(1.8)
	Events.ClientTween:Fires({ lantern }, { Transparency = 1 }, "one")
end)

local success, errorMsg = pcall(function()
	for i = 1, 4 do
		local beamPart = RepS.Package.MagicAssets.GhostlyLantern.BeamPart:Clone() :: BasePart
		beamPart.CFrame = char.PrimaryPart.CFrame * cfNew(random(-8,8), random(-1,10), random(-8,8))
		beamPart.CFrame = cfNew(beamPart.Position, monster.PrimaryPart.Position)
		beamPart.Parent = char
		Debris:AddItem(beamPart, 3)

		local att = instanceNew("Attachment")
		att.Parent = char.PrimaryPart
		beamPart.Beam.Attachment0 = beamPart.Attachment
		beamPart.Beam.Attachment1 = att
		Debris:AddItem(att, 3)

		Spawn(function()
			Spawn(function()
				for _ = 1, 10 do
					local numSeq = nsNew({nsKPNew(0, 0.5+i, 2), nsKPNew(1, 0.5+i, 2)})
					beamPart.Beam.Transparency = numSeq
					wait(0.1)
				end
			end)

			wait(0.5)
			beamPart.Fire.Enabled = false
			beamPart.Glow.Enabled = false

			wait(1)
			beamPart:Destroy()
			att:Destroy()
		end)

		wait(1)
		local explosion = RepS.Package.MagicAssets.GhostlyLantern.Explosion:Clone() :: BasePart
		explosion.CFrame = lantern.CFrame
		explosion.Parent = char
		Debris:AddItem(explosion, 1)

		Events.ClientTween:Fires({ explosion }, { Size = v3New(16, 16, 16), Transparency = 0.4 }, "twiceHalf")
		Spawn(function()
			wait(0.2)
			Events.ClientTween:Fires({ explosion }, { Size = v3New(19, 19, 19), Transparency = 1 }, "half")
		end)

		local ghost = RepS.Package.MagicAssets.GhostlyLantern.Ghost:Clone() :: MeshPart
		ghost.CFrame = lantern.CFrame * cfNew(0, 4, 0)
		ghost.CFrame = cfNew(ghost.Position, monster.PrimaryPart.Position)
		ghost.Parent = char
		Debris:AddItem(ghost, 1.5)

		local bv = instanceNew("BodyVelocity")
		bv.MaxForce = v3New(math.huge, math.huge, math.huge)
		bv.Velocity = ghost.CFrame.LookVector * 50
		bv.Parent = ghost

		Events.ClientTween:Fires({ ghost }, { Size = v3New(12,12,12) }, "twiceHalfOne")
		Spawn(function()
			wait(0.8)
			Events.ClientTween:Fires({ ghost }, { Size = v3New(22, 22, 22), Transparency = 1 }, "half")
		end)

		wait(0.5)
		if monster then
			local dmg = char:GetAttribute("Magic") :: number

			ServerUtil:ShowNumber(monster, dmg, fromRGB(170, 255, 255))

			HarukaLib:Add(monster, "Health", -dmg)
		end
	end
end)
if not success and RS:IsStudio() then warn(errorMsg) end
