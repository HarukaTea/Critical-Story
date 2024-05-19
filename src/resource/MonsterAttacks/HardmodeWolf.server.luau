--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local monster = script.Parent :: Model

local wait, random, rad = task.wait, math.random, math.rad
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local v3New = Vector3.new

local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(monster.Parent.Position + v3New(random(-32,32), 0, random(-32,32)))

	monster:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function spikeShot(target: Model)
	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)

	local pRandom = random(1, 2)

	local blast = RepS.Package.MonsterAttacks.Wolf["SpikeWolf"..pRandom]:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(monster.PrimaryPart.CFrame)

	blast.Projectile.Value = RepS.Package.MonsterAttacks.Wolf.HardmodeWolfSpike1

	blast.Parent = monster.AttackHolder.Value
end

local function spikeRain(target: Model)
	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)

	local rangePos = ServerUtil:FindPartOnRay(target.PrimaryPart.Position + v3New(random(-15, 15), 10, random(-15, 15)))

	local rangeTip = RepS.Package.MonsterAttacks.Wolf.SpikeWolf2Range:Clone() :: Part
	rangeTip.Position = rangePos
	rangeTip.Owner.Value = monster
	rangeTip.Parent = monster.AttackHolder.Value

	Debris:AddItem(rangeTip, 1)

	Spawn(function()
		wait(0.5)
		for _ = 1, random(5, 6) do
			local post = ServerUtil:FindPartOnRay(rangePos + v3New(random(-15, 15), 10, random(-15, 15)))

			local blast = RepS.Package.MonsterAttacks.Wolf.HardmodeWolfSpike2:Clone() :: Model
			blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
			blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
			blast.Owner.Value = monster
			blast.Parent = monster.AttackHolder.Value

			Debris:AddItem(blast, 10)
		end
	end)
end

local function bite(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast = RepS.Package.MonsterAttacks.Wolf.HardmodeWolf4:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3 ,0))
	blast:PivotTo(cfNew(blast.Base.Position, monster.PrimaryPart.Position))
	blast.Parent = monster.AttackHolder.Value
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			monster.PrimaryPart.Anchored = true

			spikeRain(target)
			wait(0.2)

			monster.PrimaryPart.Anchored = false

			return true
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				moving(target)
				wait(0.05)
			end

			return true
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				spikeRain(target)
				wait(0.25)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				spikeShot(target)
				wait(0.2)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 4) do
				bite(target)
				wait(0.2)
			end
		end
	})
end
attacking()