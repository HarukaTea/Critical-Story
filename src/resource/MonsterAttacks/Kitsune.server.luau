--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local monster = script.Parent :: Model
local animator = monster.AnimationController.Animator :: Animator

local wolfBiteAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.WolfBite)
local spikeShotAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.SpikeShot)

local wait, random = task.wait, math.random
local cfNew = CFrame.new
local v3New = Vector3.new


local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(monster.Parent.Position + v3New(random(-32,32), 0, random(-32,32)), { target })

	monster:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function kitsuneBlastSpirit(target: Model)
	spikeShotAnim:Play()

	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)

	local pRandom = random(1, 2)

	local blast = RepS.Package.MonsterAttacks.Fox["Kitsune"..pRandom]:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(monster.PrimaryPart.CFrame)
	blast.Parent = monster.AttackHolder.Value
end

local function bite(target)
	wolfBiteAnim:Play()

	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	monster:PivotTo(cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position))
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast = RepS.Package.MonsterAttacks.Fox.KitsuneBite:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3, 0))
	blast:PivotTo(cfNew(blast.Base.Position, monster.PrimaryPart.Position))
	blast.Parent = monster.AttackHolder.Value
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model)
			for _ = 1,3 do
				moving(target)
				wait(0.2)
			end

			return true
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				kitsuneBlastSpirit(target)
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				bite(target)
				wait(0.2)
			end
		end
	})
end
attacking()
