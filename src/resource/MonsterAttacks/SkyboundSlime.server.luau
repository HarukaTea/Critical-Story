--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local monster = script.Parent :: Model

local wait = task.wait
local cfNew = CFrame.new
local random = math.random
local v3New = Vector3.new

local function lookAt(target: Model)
	monster.PrimaryPart.CFrame = cfNew(monster.PrimaryPart.Position, target.PrimaryPart.Position)
	monster.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function slimeRepulseBlast(target: Model)
	lookAt(target)

	local blast = RepS.Package.MonsterAttacks.Slime.SkyboundSlime1:Clone()
	blast.Target.Value = target
	blast.Owner.Value = monster
	blast.Part.CFrame = monster.PrimaryPart.CFrame
	blast.Parent = monster.AttackHolder.Value
end

local function slimeCirculate(target: Model)
	lookAt(target)

	local angle = 45 + 90
	for _ = 1, 3 do
		local blast = RepS.Package.MonsterAttacks.Slime.SkyboundSlime2:Clone()
		blast.Owner.Value = monster
		blast.Target.Value = target
		blast:PivotTo(monster.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, angle, 0))
		blast.Parent = monster.AttackHolder.Value

		angle -= 45
	end

	angle = 265 - 90
	lookAt(target)
	for _ = 1, 3 do
		local blast = RepS.Package.MonsterAttacks.Slime.SkyboundSlime2:Clone()
		blast.Owner.Value = monster
		blast.Target.Value = target
		blast:PivotTo(monster.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, angle, 0))
		blast.Parent = monster.AttackHolder.Value

		angle -= 45
	end
end

local function slimeCirculateDash(target: Model)
	for _ = 1, 3 do
		local post = monster.Parent.Position + Vector3.new(random(-32, 32), 0, random(-32, 32))

		monster:PivotTo(cfNew(post))
		lookAt(target)

		local angle = 60 + 90
		for _ = 1, 2 do
			local blast = game.ReplicatedStorage.Package.MonsterAttacks.Slime.SkyboundSlime2:Clone()
			blast.Owner.Value = monster
			blast.Target.Value = target
			blast:PivotTo(monster.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, angle, 0))
			blast.Parent = monster.AttackHolder.Value

			angle -= 120
		end

		angle = 280 - 90
		lookAt(target)
		for _ = 1, 2 do
			local blast = game.ReplicatedStorage.Package.MonsterAttacks.Slime.SkyboundSlime2:Clone()
			blast.Owner.Value = monster
			blast.Target.Value = target
			blast:PivotTo(monster.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, angle, 0))
			blast.Parent = monster.AttackHolder.Value

			angle -= 120
		end
		wait(0.5)
	end
end

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			slimeCirculate(target)
			wait(0.5)
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				slimeRepulseBlast(target)
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(1, 3) do
				slimeCirculateDash(target)
			end
		end,
	})
end
attacking()
