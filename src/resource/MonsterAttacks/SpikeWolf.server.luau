--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local monster = script.Parent :: Model
local animator = monster.AnimationController.Animator :: Animator

local spikeRainAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.SpikeRain)
local spikeShotAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.SpikeShot)
local wolfBiteAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.WolfBite)

local wait, random, rad = task.wait, math.random, math.rad
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local v3New = Vector3.new

local WOLF_SP_PROJECTILE = monster:GetAttribute("SPProjectile")


local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(monster.Parent.Position + v3New(random(-32,32), 0, random(-32,32)), { target })

	monster:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function spikeShot(target: Model)
	spikeShotAnim:Play()

	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)

	local pRandom = random(1, 2)

	local blast = RepS.Package.MonsterAttacks.Wolf["SpikeWolf"..pRandom]:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(monster.PrimaryPart.CFrame)

	if WOLF_SP_PROJECTILE then
		blast.Projectile.Value = RepS.Package.MonsterAttacks.Wolf[WOLF_SP_PROJECTILE]["SpikeWolfSpike"..pRandom]
	end

	blast.Parent = monster.AttackHolder.Value
end

local function spikeRain(target: Model)
	spikeRainAnim:Play()

	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)

	local rangePos = ServerUtil:FindPartOnRay(target.PrimaryPart.Position + v3New(random(-15, 15), 10, random(-15, 15)), { target })

	local rangeTip = RepS.Package.MonsterAttacks.Wolf.SpikeWolf2Range:Clone() :: Part
	rangeTip.Position = rangePos
	rangeTip.Owner.Value = monster
	rangeTip.Parent = monster.AttackHolder.Value

	Debris:AddItem(rangeTip, 1)

	Spawn(function()
		wait(0.5)
		for _ = 1, random(5, 6) do
			local post = ServerUtil:FindPartOnRay(rangePos + v3New(random(-15, 15), 10, random(-15, 15)), { target })

			local blast: Model
			if WOLF_SP_PROJECTILE then
				blast = RepS.Package.MonsterAttacks.Wolf[WOLF_SP_PROJECTILE].SpikeWolfSpike2:Clone()
			else
				blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolfSpike2:Clone()
			end
			blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
			blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
			blast.Owner.Value = monster
			blast.Parent = monster.AttackHolder.Value

			Debris:AddItem(blast, 10)
		end
	end)
end

local function bite(target: Model)
	wolfBiteAnim:Play()

	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast: Model
	if WOLF_SP_PROJECTILE then
		blast = RepS.Package.MonsterAttacks.Wolf[WOLF_SP_PROJECTILE].SpikeWolf4:Clone()
	else
		blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf4:Clone()
	end
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post,post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3, 0))
	blast:PivotTo(cfNew(blast.Base.Position, monster.PrimaryPart.Position))
	blast.Parent = monster.AttackHolder.Value
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				moving(target)
				wait(0.1)
			end

			return true
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				spikeRain(target)
				wait(0.6)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				spikeShot(target)
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			local blackList = { "SpikeFox" }
			if table.find(blackList, monster.Name) then return true end

			for _ = 1, random(2, 4) do
				bite(target)
				wait(0.5)
			end
		end
	})
end
attacking()
