--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local wait = task.wait
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local random, rad = math.random, math.rad
local v3New = Vector3.new

local monster = script.Parent :: Model

local function stalkerShot(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.WoodLand.Stalker1:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(random(-10,10), 0, random(-10,10)))
	blast.Parent = monster.AttackHolder.Value
end

local function stalkerRain(target: Model)
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

			local blast = RepS.Package.MonsterAttacks.WoodLand.StalkerRainball:Clone() :: Model
			blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
			blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
			blast.Owner.Value = monster
			blast.Parent = monster.AttackHolder.Value

			Debris:AddItem(blast, 10)
		end
	end)
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			for _ = 1, random(3, 8) do
				stalkerShot(target)
				wait(0.2)
			end
		end,

		function (target: Model) : boolean
			stalkerRain(target)
			wait(1)
		end
	})
end
attacking()
