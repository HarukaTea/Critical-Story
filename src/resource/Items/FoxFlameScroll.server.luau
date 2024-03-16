--!strict

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
local floor = math.floor
local v3New = Vector3.new

local ITEM_ATTRIBUTES = { CD = 7, MANA_REQ = 50, COMBAT_REQ = true, MONSTER_REQ = true }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic2)
Events.MagicCasted:Fire(plr)

local fireBall = RepS.Package.MagicAssets.FoxFlameScroll.FireBall:Clone() :: BasePart
fireBall.CFrame = char.PrimaryPart.CFrame
fireBall.CFrame = cfLookAt(fireBall.Position, monster.PrimaryPart.Position)
fireBall.Parent = workspace
Debris:AddItem(fireBall, 5)

local bv = instanceNew("BodyVelocity")
bv.MaxForce = v3New(math.huge, math.huge, math.huge)
bv.Velocity = fireBall.CFrame.LookVector * 50
bv.Parent = fireBall

--- Fireball select target
local hit = false
while wait() do
	if monster and not hit then
		if not monster or not monster.PrimaryPart then break end

		if (fireBall.Position - monster.PrimaryPart.Position).Magnitude <= 4 then
			hit = true

			SkillUtil:Burn(plr, monster, 6)
			SkillUtil:MagicVFX(plr, monster)
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

			local eff = RepS.Package.MagicAssets.FoxFlameScroll.FoxBlast:Clone() :: BasePart
			eff.CFrame = monster.PrimaryPart.CFrame
			eff.Parent = workspace
			Debris:AddItem(eff, 1)

			Events.ClientTween:Fires({ eff }, { Size = v3New(24,24,24), Transparency = 1 }, "one")

			fireBall.Spirit.Enabled = false
			fireBall.CFrame = monster.PrimaryPart.CFrame
			fireBall.Anchored = true

			Events.ClientTween:Fires({ fireBall }, { Size = v3New(9,9,9), Transparency = 1 }, "one")

			delay(1, function()
				fireBall:Destroy()
			end)

			local dmg = char:GetAttribute("Magic") :: number
			ServerUtil:ShowNumber(monster, dmg, fromRGB(255, 170, 0))

			HarukaLib:Add(monster, "Health", -dmg)
		end
	else
		break
	end
end
