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

local SLIME_COLOR = fromRGB(52, 142, 64)

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

local function attacking()
	ServerUtil.MobBehaviorTree(monster, {
		function (target: Model) : boolean
			if random(1, 2) == 1 then
				slimeWave(target)
				wait(0.5)
			end

			return false
		end,

		function (target: Model) : boolean
			for _ = 1, random(2, 3) do
				lookAt(target)

				for _ = 1, 3 do
					slimeShot(target)
					wait(0.2)
				end
				wait(0.5)
			end
		end,

		function (target: Model) : boolean
			for _ = 1, random(1, 3) do
				slimeWave(target)
				wait(0.8)
			end
		end
	})
end
attacking()
