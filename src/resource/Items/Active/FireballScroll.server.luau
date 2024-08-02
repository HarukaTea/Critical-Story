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
local floor = math.floor
local one = Vector3.one

local ITEM_ATTRIBUTES = { CD = 6, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Magic2 })
Events.PlayAnimation.Fire(plr, { AnimId = "MagicCastedAnim1" })

local fireBall = RepS.Package.MagicAssets.FireBall:Clone() :: Part
fireBall.CFrame = char.PrimaryPart.CFrame
fireBall.CFrame = cfLookAt(fireBall.Position, monster.PrimaryPart.Position)
fireBall.Parent = workspace
Debris:AddItem(fireBall, 5)

local bv = instanceNew("BodyVelocity")
bv.MaxForce = one * math.huge
bv.Velocity = fireBall.CFrame.LookVector * 50
bv.Parent = fireBall

--- Fireball select target
local hit = false
local success, errorMsg = pcall(function()
	while wait(0.01) do
		if hit then break end

		if (fireBall.Position - monster.PrimaryPart.Position).Magnitude <= 4 then
			hit = true

			BuffEffectsUtil:Burn(char, monster, 1, 6)
			BuffEffectsUtil:MagicVFX(monster)
			Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.Magic1 })

			fireBall.Spirit.Enabled = false
			fireBall.CFrame = monster.PrimaryPart.CFrame
			fireBall.Anchored = true
			Debris:AddItem(fireBall, 1)

			Events.ClientTween.FireAll({ Objs = { fireBall }, Goal = { Size = one * 9, Transparency = 1 }, TweenInfo = "one" })

			local dmg = floor(char:GetAttribute("Magic") / 2)
			HarukaLib:AddAttr(monster, "Health", -dmg)

			ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 170, 0))
		end
	end
end)
if not success and RS:IsStudio() then warn(errorMsg) end
