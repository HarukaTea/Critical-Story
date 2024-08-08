--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local wait = task.wait
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local random, rad = math.random, math.rad
local v3New = Vector3.new

local monster = script.Parent :: Model

local STALKER_SP_PROJECTILE = monster:GetAttribute("SPProjectile") :: string

local function lookAt(target: Model)
	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function stalkerShot(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	local blast: Model
	if STALKER_SP_PROJECTILE then
		blast = RepS.Package.MonsterAttacks.WoodLand[STALKER_SP_PROJECTILE].Stalker1:Clone() :: Model
	else
		blast = RepS.Package.MonsterAttacks.WoodLand.Stalker1:Clone() :: Model
	end
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(random(-10,10), 0, random(-10,10)))
	blast.Parent = monster.AttackHolder.Value
end

local function stalkerBite(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	lookAt(target)

	local blast = RepS.Package.MonsterAttacks.WoodLand.StalkerBite:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3, 0))
	blast:PivotTo(cfNew(blast.Base.Position, monster.PrimaryPart.Position))
	blast:PivotTo(blast.Base.CFrame * cfAngles(0, rad(random(-180, 180)), 0))
	blast.Parent = monster.AttackHolder.Value

	local blast2 = RepS.Package.MonsterAttacks.WoodLand.StalkerBite:Clone() :: Model
	blast2.Owner.Value = monster
	blast2:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3, 0) * CFrame.fromEulerAnglesXYZ(90, 0, 0))
	blast2:PivotTo(cfNew(blast2.Base.Position, monster.PrimaryPart.Position))
	blast2:PivotTo(blast2.Base.CFrame * cfAngles(0, rad(random(-180, 180)), 0))
	blast2.Parent = monster.AttackHolder.Value
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			for _ = 1, 16 do
				stalkerShot(target)
				wait(0.03)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, 2 do
				stalkerBite(target)
				wait(0.6)
			end
		end
	})
end
attacking()
