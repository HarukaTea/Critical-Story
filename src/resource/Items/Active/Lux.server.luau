--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local instanceNew = Instance.new
local cfLookAt = CFrame.lookAt
local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local ITEM_ATTRIBUTES = { CD = 6, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.PlayAnimation:Fire(plr, "MagicCastedAnim1")

local luxBall = RepS.Package.MagicAssets.Lux.LuxBall:Clone() :: Part
luxBall.CFrame = char.PrimaryPart.CFrame
luxBall.CFrame = cfLookAt(luxBall.Position, monster.PrimaryPart.Position)
luxBall.Parent = workspace
Debris:AddItem(luxBall, 5)

local bv = instanceNew("BodyVelocity")
bv.MaxForce = v3New(1, 1, 1) * math.huge
bv.Velocity = luxBall.CFrame.LookVector * 50
bv.Parent = luxBall

--- Fireball select target
local hit = false
local success, errorMsg = pcall(function()
	while wait(0.01) do
		if hit then break end

		if (luxBall.Position - monster.PrimaryPart.Position).Magnitude <= 4 then
			hit = true

			BuffEffectsUtil:MagicVFX(monster)
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

			local eff = RepS.Package.MagicAssets.Lux.Flashed:Clone() :: BasePart
			eff.CFrame = monster.PrimaryPart.CFrame
			eff.Parent = workspace
			Debris:AddItem(eff, 1)

			Events.ClientTween:Fires({ eff }, { Size = v3New(24,24,24), Transparency = 1 }, "one")

			luxBall.Spirit.Enabled = false
			luxBall.CFrame = monster.PrimaryPart.CFrame
			luxBall.Anchored = true
			Debris:AddItem(luxBall, 1)

			Events.ClientTween:Fires({ luxBall }, { Size = v3New(1, 1, 1) * 9, Transparency = 1 }, "one")

			local dmg = char:GetAttribute("Magic")
			HarukaLib:AddAttr(monster, "Health", -dmg)

			ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 255, 0))
		end
	end
end)
if not success and RS:IsStudio() then warn(errorMsg) end
