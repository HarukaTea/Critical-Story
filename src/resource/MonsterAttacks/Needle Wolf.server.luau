--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(game:GetService("ServerScriptService").Modules.Utils.ServerUtil)

local char = script.Parent :: Model

local wait = task.wait
local v3New = Vector3.new
local random = math.random
local cfNew = CFrame.new

local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(char.Parent.Position + v3New(random(-32,32), 0, random(-32,32)), { target })

	char:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function bite(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf4:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3 ,0))
	blast:PivotTo(cfNew(blast.Base.Position, char.PrimaryPart.Position))

	blast.Parent = char.Holder.Value
end

local function attacking()
	wait(0.5)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[random(1, #list)] :: ObjectValue

		for i = 1, random(2, 3) do
			moving(target.Value)
			wait(0.2)
		end

		wait(0.3)
		for i = 1, random(2, 4) do
			bite(target.Value)
			wait(0.5)
		end

		attacking()
	end
end

wait(0.5)
attacking()
