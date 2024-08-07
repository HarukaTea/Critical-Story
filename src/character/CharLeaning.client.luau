--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local MOMENTUM_FACTOR = 0.008
local MIN_MOMENTUM = 0.05
local MAX_MOMENTUM = 0.1
local SPEED = 15

local char = script.Parent :: Model
local humanoid = char:WaitForChild("Humanoid") :: Humanoid
local HRP = char:WaitForChild("HumanoidRootPart") :: BasePart

local m6d = HRP.RootJoint :: Motor6D
local originalM6dC0 = m6d.C0

local v3New = Vector3.new
local clamp, abs = math.clamp, math.abs
local cfAngles = CFrame.Angles

Add(RS.PostSimulation:Connect(function(deltaTime)
	local direction = HRP.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
	local momentum = HRP.CFrame:VectorToObjectSpace(HRP.Velocity) * MOMENTUM_FACTOR

	momentum = v3New(clamp(abs(momentum.X), MIN_MOMENTUM, MAX_MOMENTUM), 0, clamp(abs(momentum.Z), MIN_MOMENTUM, MAX_MOMENTUM))

	local x = direction.X * momentum.X
	local z = (direction.Z * momentum.Z) / 2
	local angles = {-z, -x, 0}

	m6d.C0 = m6d.C0:Lerp(originalM6dC0 * cfAngles(unpack(angles)), deltaTime * SPEED)
end))

--// Clear
humanoid.Died:Once(Empty)
