--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = require(game:GetService("ServerScriptService").Modules.Utils.ServerUtil)

local char = script.Parent

local wait = task.wait
local cfNew = CFrame.new
local random = math.random
local v3New = Vector3.new
local fromRGB = Color3.fromRGB

local SLIME_COLOR = fromRGB(52, 142, 64)

local function lookAt(target: Model)
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position)
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function slimeShot(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime1:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value
end

local function slimeWave(target: Model)
	lookAt(target)
	local post = ServerUtil:FindPartOnRay(char.PrimaryPart.Position, { target })

	local blast = RepS.Package.MonsterAttacks.Slime.Slime2:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post, post + char.PrimaryPart.CFrame.LookVector))
	blast:SetAttribute("SlimeColor", SLIME_COLOR)
	blast.Parent = char.Holder.Value
end

local function attacking()
	wait(1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[random(1, #list)]

		local style = random(1, 2)

		if style == 1 then
			if random(1, 2) == 1 then
				slimeWave(target.Value)
				wait(0.5)
			end

			for q = 1, random(2, 3) do
				lookAt(target.Value)

				for i = 1, 3 do
					slimeShot(target.Value)
					wait(0.2)
				end
				wait(0.5)
			end

		elseif style == 2 then
			for i = 1, random(1, 3) do
				slimeWave(target.Value)
				wait(0.8)
			end
		end

		attacking()
	end
end

wait(0.5)
attacking()
