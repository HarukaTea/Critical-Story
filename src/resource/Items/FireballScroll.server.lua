--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local Events = HarukaFrameworkServer.Events
local HarukaLib = HarukaFrameworkServer.HarukaLib
local ServerUtil = HarukaFrameworkServer.ServerUtil
local SkillUtil = HarukaFrameworkServer.SkillUtil

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait = task.wait
local instanceNew = Instance.new
local cfLookAt = CFrame.lookAt
local fromRGB = Color3.fromRGB
local floor = math.floor
local one = Vector3.one

local ITEM_ATTRIBUTES = { CD = 10, MANA_REQ = 100, COMBAT_REQ = true, MONSTER_REQ = true, IS_SKILL = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then
	return
end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)

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
while wait(0.01) do
	if monster and not hit then
		if not monster or not monster.PrimaryPart then break end

		if (fireBall.Position - monster.PrimaryPart.Position).Magnitude <= 4 then
			hit = true

			SkillUtil:MagicVFX(plr, monster)
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

			fireBall.Spirit.Enabled = false
			fireBall.CFrame = monster.PrimaryPart.CFrame
			fireBall.Anchored = true
			Debris:AddItem(fireBall, 1)

			Events.ClientTween:Fires({ fireBall }, { Size = one * 9, Transparency = 1 }, "one")

			local dmg = floor(char:GetAttribute("Magic") / 2)
            HarukaLib:Add(monster, "Health", -dmg)

			ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 170, 0))

			SkillUtil:Burn(plr, monster, 4)
		end
	else
		break
	end
end
