--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model

local wait, random, rad = task.wait, math.random, math.rad
local cfNew, cfLookat, cfAngles = CFrame.new, CFrame.lookAt, CFrame.Angles
local v3New = Vector3.new

local function lookAt(target: Model)
	local pos, pos2 = target.PrimaryPart.Position, char.PrimaryPart.Position :: Vector3
	local x, y, z = cfLookat(pos2, pos):ToOrientation()

	char.PrimaryPart.CFrame = cfNew(pos2) * cfAngles(0, y, 0)
	return pos, pos2, y
end

local function moving(target: Model)
	local pos, pos2, y = lookAt(target)

	TS:Create(
		char.PrimaryPart,
		AssetBook.TweenInfos.onceHalf,
		{ CFrame = cfNew(v3New(pos.X, pos2.Y, pos.Z)) * cfAngles(0, y, 0) }):Play()
	wait(0.35)
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
	rangeTip:AddTag("MonsterAttack")
	rangeTip.Parent = char.Holder.Value

	Debris:AddItem(rangeTip, 1)

	for _ = 1, random(5, 6) do
		local post = ServerUtil:FindPartOnRay(
			rangePos + v3New(random(-15, 15), 10, random(-15, 15)),
			{ target, char, rangeTip }
		)

		local blast = RepS.Package.MonsterAttacks.Wolf.SpikeWolfSpike2:Clone() :: Model
		blast:PivotTo(cfNew(post, post + blast.Base.CFrame.LookVector))
		blast:PivotTo(cfNew(post) * cfAngles(0, rad(random(1, 360)), 0))
		blast.Owner.Value = char

		blast.Parent = char.Holder.Value

		Debris:AddItem(blast, 10)
	end
end

local function attacking()
	wait(0.5)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[random(1, #list)] :: ObjectValue

		local style = random(1, 2)

		if style == 1 then
			for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.3)
			for i = 1, random(2, 3) do
				spikeShot(target.Value)
				wait(0.5)
			end
			wait(0.3)
			if random(1, 2) == 1 then
				spikeRain(target.Value)
				wait(0.6)
			end
		elseif style == 2 then
			for i = 1, random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.3)
			for i = 1, random(2, 3) do
				spikeRain(target.Value)
				wait(0.6)
			end
		end

		attacking()
	end
end

wait(0.5)
attacking()
