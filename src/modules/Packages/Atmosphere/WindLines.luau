--!nocheck

local RunService = game:GetService("RunService")

local Terrain = workspace:FindFirstChildOfClass("Terrain")

local OFFSET = Vector3.new(0, 0.1, 0)

local WindLines = {}

WindLines.UpdateConnection = nil
WindLines.UpdateQueue = table.create(10)

function WindLines:_create()
	local Lifetime = WindLines.Lifetime
	local Position = (workspace.CurrentCamera.CFrame
		* CFrame.Angles(
			math.rad(math.random(-30, 70)),
			math.rad(math.random(-80, 80)),
			0))
		* CFrame.new(0, 0, math.random(200, 600) * -0.1).Position

	local Direction = WindLines.Direction
	local Speed = WindLines.Speed

	local Attachment0 = Instance.new("Attachment")
	local Attachment1 = Instance.new("Attachment")

	local Trail = Instance.new("Trail")
	Trail.Attachment0 = Attachment0
	Trail.Attachment1 = Attachment1
	Trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.2, 1),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 0.3),
	})
	Trail.Transparency = NumberSequence.new(0.7)
	Trail.FaceCamera = true
	Trail.Parent = Attachment0

	Attachment0.WorldPosition = Position
	Attachment1.WorldPosition = Position + OFFSET

	local WindLine = {
		Attachment0 = Attachment0,
		Attachment1 = Attachment1,
		Trail = Trail,
		Lifetime = Lifetime + (math.random(-10, 10) * 0.1),
		Position = Position,
		Direction = Direction,
		Speed = Speed + (math.random(-10, 10) * 0.1),
		StartClock = os.clock(),
		Seed = math.random(1, 1000) * 0.1,
	}
	WindLines.UpdateQueue[#WindLines.UpdateQueue + 1] = WindLine

	Attachment0.Parent = Terrain
	Attachment1.Parent = Terrain
end

function WindLines:Init(Settings: table)
	-- Set defaults
	WindLines.Lifetime = Settings.Lifetime or 3
	WindLines.Direction = Settings.Direction or Vector3.new(1, 0, 0)
	WindLines.Speed = Settings.Speed or 6
	WindLines.LastSpawned = os.clock()

	local SpawnRate = 1 / (Settings.SpawnRate or 25)

	-- Setup logic loop
	WindLines.UpdateConnection = RunService.Heartbeat:Connect(function()
		local Clock = os.clock()

		-- Spawn handler
		if Clock - WindLines.LastSpawned > SpawnRate then
			WindLines:_create()
			WindLines.LastSpawned = Clock
		end

		-- Update queue handler
		for i, WindLine in WindLines.UpdateQueue do
			local AliveTime = Clock - WindLine.StartClock
			if AliveTime >= WindLine.Lifetime then
				-- Destroy the objects
				WindLine.Attachment0:Destroy()
				WindLine.Attachment1:Destroy()
				WindLine.Trail:Destroy()

				-- unordered remove at this index
				local Length = #WindLines.UpdateQueue
				WindLines.UpdateQueue[i] = WindLines.UpdateQueue[Length]
				WindLines.UpdateQueue[Length] = nil

				continue
			end

			WindLine.Trail.MaxLength = 20 - (20 * (AliveTime / WindLine.Lifetime))

			local SeededClock = (Clock + WindLine.Seed) * (WindLine.Speed * 0.2)
			local StartPos = WindLine.Position
			WindLine.Attachment0.WorldPosition = (CFrame.new(StartPos, StartPos + WindLine.Direction) * CFrame.new(0, 0, WindLine.Speed * -AliveTime
			)).Position + Vector3.new(
				math.sin(SeededClock) * 0.5,
				math.sin(SeededClock) * 0.8,
				math.sin(SeededClock) * 0.5
			)

			WindLine.Attachment1.WorldPosition = WindLine.Attachment0.WorldPosition + OFFSET
		end
	end)
end

function WindLines:Cleanup()
	if WindLines.UpdateConnection then
		WindLines.UpdateConnection:Disconnect()
		WindLines.UpdateConnection = nil
	end

	for _, WindLine in WindLines.UpdateQueue do
		WindLine.Attachment0:Destroy()
		WindLine.Attachment1:Destroy()
		WindLine.Trail:Destroy()
	end
	table.clear(WindLines.UpdateQueue)
end

return WindLines
