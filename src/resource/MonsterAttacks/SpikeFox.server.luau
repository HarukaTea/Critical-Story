--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model

local wait, random, rad = task.wait, math.random, math.rad
local cfNew, cfAngles = CFrame.new, CFrame.Angles
local v3New = Vector3.new


local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(char.Parent.Position + v3New(random(-32,32), 0, random(-32,32)))

	char:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end

local function spikeShot(target: Model)
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position)

	local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf1:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(char.PrimaryPart.CFrame)
	blast.Parent = char.AttackHolder.Value

	if char.Head:FindFirstChild("Encountered") then return end

	local attention = RepS.Package.Effects.Encountered:Clone() :: BillboardGui
	attention.Parent = char.Head

	Debris:AddItem(attention, 1.2)
end

local function spikeRain(target: Model)
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position)

	local rangePos = ServerUtil:FindPartOnRay(target.PrimaryPart.Position + v3New(random(-15, 15), 10, random(-15, 15)))

	local rangeTip = RepS.Package.MonsterAttacks.Wolf.SpikeWolf2Range:Clone() :: Part
	rangeTip.Position = rangePos
	rangeTip.Owner.Value = char
	rangeTip.Parent = char.AttackHolder.Value

	Debris:AddItem(rangeTip, 1)

	Spawn(function()
		wait(0.5)
		for _ = 1, random(5, 6) do
			local post = ServerUtil:FindPartOnRay(rangePos + v3New(random(-15, 15), 10, random(-15, 15)))

			local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolfSpike2:Clone() :: Model
			blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
			blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
			blast.Owner.Value = char

			blast.Parent = char.AttackHolder.Value

			Debris:AddItem(blast, 10)
		end
	end)
end

local function attacking()
	wait(0.5)
	if char.TargetPlayers:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetPlayers:GetChildren()
		local target = list[random(1, #list)] :: ObjectValue

		local style = random(1, 2)

		if style == 1 then
			for _ = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.3)
			for _ = 1, random(2, 3) do
				spikeShot(target.Value)
				wait(0.5)
			end

			if random(1, 2) == 1 then
				char.PrimaryPart.Anchored = true

				spikeRain(target.Value)
				wait(0.5)

				char.PrimaryPart.Anchored = false
			end

		elseif style == 2 then
			for _ = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end

			wait(0.3)
			for _ = 1, random(2, 3) do
				spikeRain(target.Value)
				wait(0.6)
			end

			if random(1, 2) == 1 then
				char.PrimaryPart.Anchored = true

				spikeRain(target.Value)
				wait(0.5)

				char.PrimaryPart.Anchored = false
			end
		end

		attacking()
	end
end
attacking()
