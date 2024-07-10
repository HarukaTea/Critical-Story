--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local monster = script.Parent :: Model
local animator = monster.AnimationController.Animator :: Animator

local blastAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.SlimeIdle)
local spinAnim = animator:LoadAnimation(RepS.Package.Animations.MonsterAnims.SlimeSpin)

local wait = task.wait
local cfNew = CFrame.new
local random = math.random
local v3New = Vector3.new

local SLIME_COLOR = monster:GetAttribute("SlimeColor")

local function lookAt(target: Model)
	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function slimeShot(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	if monster:GetAttribute("SPProjectile") then
		blast.Projectile.Value = RepS.Package.MonsterAttacks.Slime[monster:GetAttribute("SPProjectile")]
	end

	blast.Parent = monster.AttackHolder.Value
end

local function slimeWave(target: Model)
	lookAt(target)
	local post = ServerUtil:FindPartOnRay(monster.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime2:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + monster.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	if monster:GetAttribute("SPProjectile") then
		blast.Projectile.Value = RepS.Package.MonsterAttacks.Slime[monster:GetAttribute("SPProjectile")]
	end

	blast.Parent = monster.AttackHolder.Value
end

local function slimeBarrage(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	if monster:GetAttribute("SPProjectile") then
		blast.Projectile.Value = RepS.Package.MonsterAttacks.Slime[monster:GetAttribute("SPProjectile")]
	end

	blast.Parent = monster.AttackHolder.Value

	for _ = 1, random(3, 5) do
		local postR = ServerUtil:FindPartOnRay(monster.Parent.Position + v3New(random(-32,32), 20, random(-32,32)))

		local blastR = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
		blastR.Owner.Value = monster
		blastR:PivotTo(cfNew(postR, postR + target.PrimaryPart.CFrame.LookVector))

		blastR:SetAttribute("SlimeColor", SLIME_COLOR)
		if monster:GetAttribute("SPProjectile") then
			blastR.Projectile.Value = RepS.Package.MonsterAttacks.Slime[monster:GetAttribute("SPProjectile")]
		end

		blastR.Parent = monster.AttackHolder.Value
	end

	wait(0.35)
	lookAt(target)

	spinAnim:Play()

	local blastS = RepS.Package.MonsterAttacks.Slime.SlimeSpin:Clone() :: Model
	blastS.Owner.Value = monster
	blastS:PivotTo(monster.PrimaryPart.CFrame)

	blastS:SetAttribute("SlimeColor", SLIME_COLOR)

	blastS.Parent = monster.AttackHolder.Value

	monster.PrimaryPart.CFrame *= cfNew(0,0,-2.5)
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			local comboRandom = random(1, 3)

			if comboRandom == 1 then
				slimeWave(target)
				wait(0.5)

			elseif comboRandom == 2 then
				slimeBarrage(target)
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			if random(1, 2) == 1 then
				slimeWave(target)
				wait(0.5)
			end

			return false
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				blastAnim:Play()
				lookAt(target)

				for _ = 1, 5 do
					slimeShot(target)
					wait(0.05)
				end
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				slimeWave(target)
				wait(0.8)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(2,4) do
                slimeBarrage(target)
                wait(0.5)
            end
		end,
	})
end
attacking()
