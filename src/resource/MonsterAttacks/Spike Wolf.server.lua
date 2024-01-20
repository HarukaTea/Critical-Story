--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local ServerUtil = HarukaFrameworkServer.ServerUtil

local char = script.Parent

local wait = task.wait
local v3New = Vector3.new
local random, rad = math.random, math.rad
local cfNew, cfAngles = CFrame.new, CFrame.Angles

local function moving(target: Model)
	local post = ServerUtil:FindPartOnRay(char.Parent.Position + v3New(random(-32,32), 0, random(-32,32)), { target })

	char:PivotTo(cfNew(post, post + target.PrimaryPart.CFrame.LookVector) * cfNew(0, 1.5, 0))
	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)
end
local function lookAt(target: Model)
	local pos, pos2 = target.PrimaryPart.Position, char.PrimaryPart.Position :: Vector3
	local x, y, z = cfNew(pos2, pos):ToOrientation()

	char.PrimaryPart.CFrame = cfNew(pos2) * cfAngles(0, y, 0)
	return pos, pos2, y
end

local function spikeShot(target: Model)
	lookAt(target)

	local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf1:Clone() :: Model
	blast.Owner.Value = char
	blast:PivotTo(char.PrimaryPart.CFrame)
	blast.Parent = char.Holder.Value

    if char.Head:FindFirstChild("Encountered") then return end

	local attention = RepS.Package.Effects.Encountered:Clone() :: BillboardGui
	attention.Parent = char.Head

	Debris:AddItem(attention, 1.2)
end

local function spikeRain(target: Model)
	lookAt(target)

	local rangePos = ServerUtil:FindPartOnRay(
		target.PrimaryPart.Position + v3New(random(-15, 15), 10, random(-15, 15)),
		{ target, char }
	)

	local rangeTip = RepS.Package.MonsterAttacks.Wolf.SpikeWolf2Range:Clone() :: Part
	rangeTip.Position = rangePos
	rangeTip.Owner.Value = char
	rangeTip.Parent = char.Holder.Value
	Debris:AddItem(rangeTip, 1)

	for i = 1, random(5, 6) do
		local post = ServerUtil:FindPartOnRay(
			rangePos + v3New(random(-15, 15), 10, random(-15, 15)),
			{ target, char, rangeTip }
		)

		local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolfSpike2:Clone() :: Model
		blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
		blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
		blast.Owner.Value = char
		blast.Parent = char.Holder.Value

		blast.Spike:Play()

		Debris:AddItem(blast, 10)
	end
end

local function bite(target: Model)
	local post = ServerUtil:FindPartOnRay(target.PrimaryPart.Position, { target })

	char:PivotTo(cfNew(char.PrimaryPart.Position, target.PrimaryPart.Position))
	char.PrimaryPart.Orientation *= v3New(0, 1, 1)

	local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolf4:Clone()
	blast.Owner.Value = char
	blast:PivotTo(cfNew(post,post+target.PrimaryPart.CFrame.LookVector) * cfNew(0, 3 ,0))
	blast:PivotTo(cfNew(blast.Base.Position, char.PrimaryPart.Position))
	blast.Parent = char.Holder.Value
end

local function attacking()
	wait(0.5)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[random(1, #list)]

		local style = random(1, 3)

		if style == 1 then
			for i = 1, random(2,3) do
				moving(target.Value)
				wait(0.2)
			end

			wait(0.3)
			for i = 1, random(2,3) do
				spikeShot(target.Value)
				wait(0.5)
			end

			if random(1, 2) == 1 then
				spikeRain(target.Value)
				wait(0.5)
			end

        elseif style == 2 then
            for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.2)
			end

			wait(0.3)
			for i = 1, random(2, 3) do
				spikeRain(target.Value)
				wait(0.6)
			end

			if random(1, 2) == 1 then
				spikeShot(target.Value)
				wait(0.5)
			end

        elseif style == 3 then
            for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.2)
			end

			wait(0.3)
			for i = 1, random(2, 4) do
				bite(target.Value)
				wait(0.5)
			end

            local combo = random(1, 2)
			if combo == 1 then
				spikeShot(target.Value)
				wait(0.5)

			elseif combo == 2 then
				spikeRain(target.Value)
				wait(0.5)
			end
        end

		attacking()
	end
end

wait(0.5)
attacking()