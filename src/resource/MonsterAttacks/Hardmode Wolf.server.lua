local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.HarukaFrameworkClient).AssetBook
local ServerUtil = require(SSS.Modules.HarukaFrameworkServer).ServerUtil

local char = script.Parent

--[[
	TODO: rewrite
]]

local wait = task.wait

local function lookAt(target: Model)
	local pos, pos2 = target.PrimaryPart.Position, char.PrimaryPart.Position :: Vector3
	local x, y, z = CFrame.lookAt(pos2, pos):ToOrientation()

	char.PrimaryPart.CFrame = CFrame.new(pos2) * CFrame.Angles(0, y, 0)
	return pos, pos2, y
end

local function moving(target: Model)
	local pos, pos2, y = lookAt(target)

	TS:Create(
		char.PrimaryPart,
		AssetBook.TweenInfos.onceHalf,
		{ CFrame = CFrame.new(Vector3.new(pos.X, pos2.Y, pos.Z)) * CFrame.Angles(0, y, 0) }
	):Play()
	wait(0.35)
end

function attacking()
	wait(0.1)
	if char.TargetingList:FindFirstChildOfClass("ObjectValue") then
		local list = char.TargetingList:GetChildren()
		local target = list[math.random(1, #list)]

		local num = math.random(2)
		local style = num == 1 and "SpikeShot" or "SpikeRain"
		if style == "SpikeShot" then
			for i = 1, math.random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.1)
			for i = 1, math.random(2, 3) do
				char.HumanoidRootPart.Anchored = true
				spikeShot(target.Value)
				wait(0.1)
				char.HumanoidRootPart.Anchored = false
			end
		elseif style == "SpikeRain" then
			for i = 1, math.random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.1)
			for i = 1, math.random(2, 3) do
				char.HumanoidRootPart.Anchored = true
				spikeRain(target.Value)
				wait(0.1)
				char.HumanoidRootPart.Anchored = false
			end
		elseif style == "Bite" then
			for i = 1, math.random(2, 3) do
				moving(target.Value)
				wait(0.1)
			end
			wait(0.1)

			for i = 1, math.random(2, 4) do
				char.HumanoidRootPart.Anchored = true
				bite(target.Value)
				wait(0.1)
				char.HumanoidRootPart.Anchored = false
			end
		end

		attacking()
	end
end

function spikeShot(target)
	local rotatingPart = Instance.new("Part")
	rotatingPart.Transparency = 1
	rotatingPart.Anchored = true
	rotatingPart.CanCollide = false
	rotatingPart.CFrame = char.HumanoidRootPart.CFrame
	rotatingPart.Orientation = char.HumanoidRootPart.Orientation * Vector3.new(0, 1, 1)
	rotatingPart.Parent = workspace

	char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))
	char:PivotTo(rotatingPart.CFrame)
	rotatingPart:Destroy()

	local blast = RepS.Package.MonsterAttacks.Wolf.HardmodeWolf1:Clone()
	blast.Owner.Value = char
	blast:PivotTo(char.HumanoidRootPart.CFrame)
	blast.Parent = char.Holder.Value
end

function spikeRain(target)
	local rotatingPart = Instance.new("Part")
	rotatingPart.Transparency = 1
	rotatingPart.Anchored = true
	rotatingPart.CanCollide = false
	rotatingPart.CFrame = char.HumanoidRootPart.CFrame
	rotatingPart.Orientation = char.HumanoidRootPart.Orientation * Vector3.new(0, 1, 1)
	rotatingPart.Parent = workspace

	char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))
	char:PivotTo(rotatingPart.CFrame)
	rotatingPart:Destroy()

	local blast = RepS.Package.MonsterAttacks.Wolf.HardmodeWolf3:Clone()
	blast.Owner.Value = char
	blast:PivotTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0))
	blast.Parent = char.Holder.Value
end

function bite(target)
	local post = ServerUtil:FindPartOnRay(target.HumanoidRootPart.Position, { target })

	local rotatingPart = Instance.new("Part")
	rotatingPart.Transparency = 1
	rotatingPart.Anchored = true
	rotatingPart.CanCollide = false
	rotatingPart.Parent = workspace
	char:PivotTo(CFrame.new(char.HumanoidRootPart.Position, target.HumanoidRootPart.Position))
	rotatingPart.CFrame = char.HumanoidRootPart.CFrame
	rotatingPart.Orientation = char.HumanoidRootPart.Orientation * Vector3.new(0, 1, 1)
	char:PivotTo(rotatingPart.CFrame)

	local blast = RepS.Package.MonsterAttacks.Wolf.HardmodeWolf4:Clone()
	blast.Owner.Value = char
	blast:PivotTo(CFrame.new(post, post + target.HumanoidRootPart.CFrame.LookVector) * CFrame.new(0, 3, 0))
	blast:PivotTo(CFrame.new(blast.Base.Position, char.HumanoidRootPart.Position))

	rotatingPart.CFrame = blast.Base.CFrame
	rotatingPart.Orientation = blast.Base.Orientation * Vector3.new(0, 1, 1)

	blast:PivotTo(rotatingPart.CFrame)
	blast.Parent = char.Holder.Value

	rotatingPart:Destroy()
end

wait(0.3)
attacking()
