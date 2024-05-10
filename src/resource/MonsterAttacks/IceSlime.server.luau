--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local monster = script.Parent :: Model

local wait = task.wait
local cfNew = CFrame.new
local random = math.random
local v3New = Vector3.new
local fromRGB = Color3.fromRGB

local SLIME_COLOR = fromRGB(128, 187, 219)

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

	blast.Parent = monster.AttackHolder.Value
end

local function slimeWave(target: Model)
	lookAt(target)
	local post = ServerUtil:FindPartOnRay(monster.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime2:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + monster.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)

	blast.Parent = monster.AttackHolder.Value
end

local function slimeDiveDown()
	local post = ServerUtil:FindPartOnRay(monster.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime3:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + monster.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)

	blast.Parent = monster.AttackHolder.Value

	local divedown = blast.Base.CFrame * cfNew(0,-8,0)
	wait(0.5)
	monster.PrimaryPart.CFrame = divedown
end

local function slimeDiveUp(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime3:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)

	blast.Parent = monster.AttackHolder.Value
	monster.PrimaryPart.CFrame = blast.Base.CFrame * cfNew(0,-8,0)

	local diveup = blast.Base.CFrame * cfNew(0, monster.PrimaryPart.Size.Y/2, 0)

	wait(0.5)
	monster.PrimaryPart.CFrame = diveup
end

local function slimeBarrage(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = monster
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))

	blast:SetAttribute("SlimeColor", SLIME_COLOR)

	blast.Parent = monster.AttackHolder.Value

	for _ = 1, random(3, 5) do
		local postR = ServerUtil:FindPartOnRay(monster.Parent.Position + v3New(random(-32,32), 20, random(-32,32)))

		local blastR = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
		blastR.Owner.Value = monster
		blastR:PivotTo(cfNew(postR, postR + target.PrimaryPart.CFrame.LookVector))

		blastR:SetAttribute("SlimeColor", SLIME_COLOR)

		blastR.Parent = monster.AttackHolder.Value
	end

	wait(0.5)
	lookAt(target)

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
				wait(0.35)

			elseif comboRandom == 2 then
				slimeBarrage(target)
				wait(0.35)
			end
		end,

		function (target: Model) : boolean
			if random(1, 2) == 1 then
				slimeWave(target)
				wait(0.35)
			end

			return false
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				lookAt(target)

				for _ = 1, 5 do
					slimeShot(target)
					wait(0.02)
				end
				wait(0.35)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, 3 do
				slimeWave(target)
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			slimeDiveDown()

            monster:SetAttribute("CantAttack", true)

            wait(0.5)
            slimeDiveUp(target)
            monster:SetAttribute("CantAttack", nil)
		end,

		function (target: Model) : boolean
			for _ = 1, random(2,4) do
                slimeBarrage(target)
                wait(0.35)
            end
		end,
	})
end
attacking()
