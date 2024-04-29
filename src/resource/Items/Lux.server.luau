--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)
local monster = char.CharStats.TargetMonster.Value :: Model

local wait, delay = task.wait, task.delay
local instanceNew = Instance.new
local cfLookAt = CFrame.lookAt
local fromRGB = Color3.fromRGB
local v3New = Vector3.new

local ITEM_ATTRIBUTES = { CD = 7, MANA_REQ = 50, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.MagicCasted:Fire(plr)

local luxBall = RepS.Package.MagicAssets.Lux.LuxBall:Clone() :: BasePart
luxBall.CFrame = char.PrimaryPart.CFrame
luxBall.CFrame = cfLookAt(luxBall.Position, monster.PrimaryPart.Position)
luxBall.Parent = workspace
Debris:AddItem(luxBall, 5)

local bv = instanceNew("BodyVelocity")
bv.MaxForce = v3New(math.huge, math.huge, math.huge)
bv.Velocity = luxBall.CFrame.LookVector * 50
bv.Parent = luxBall

--- Fireball select target
local hit = false
while wait() do
	if monster and not hit then
		if not monster or not monster.PrimaryPart then break end

		if (luxBall.Position - monster.PrimaryPart.Position).Magnitude <= 4 then
			hit = true

			SkillUtil:MagicVFX(monster)
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

			local eff = RepS.Package.MagicAssets.Lux.Flashed:Clone() :: BasePart
			eff.CFrame = monster.PrimaryPart.CFrame
			eff.Parent = workspace
			Debris:AddItem(eff, 1)

			Events.ClientTween:Fires({ eff }, { Size = v3New(24,24,24), Transparency = 1 }, "one")

			luxBall.Spirit.Enabled = false
			luxBall.CFrame = monster.PrimaryPart.CFrame
			luxBall.Anchored = true

			Events.ClientTween:Fires({ luxBall }, { Size = v3New(9,9,9), Transparency = 1 }, "one")

			delay(1, function()
				luxBall:Destroy()
			end)

			local dmg = char:GetAttribute("Magic") :: number
			ServerUtil:ShowNumber(monster, dmg, fromRGB(217, 255, 0))

			HarukaLib:Add(monster, "Health", -dmg)
		end
	else
		break
	end
end
