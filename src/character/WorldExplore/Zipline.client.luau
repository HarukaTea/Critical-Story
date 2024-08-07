--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Bezier = require(RepS.Modules.Packages.DataLibs.Bezier)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model
local humanoid = char.Humanoid :: Humanoid

local isRiding = false
local curvePointsSet = {}

if not workspace:WaitForChild("MapComponents", 999):FindFirstChild("Ziplines") then return end

local function setupZipline()
    for _, child: Instance in workspace.MapComponents.Ziplines:GetDescendants() do
        if child:HasTag("Zipline") and child:IsA("Model") then
            --- sort points
            local points = {} :: { BasePart }
            for _, point: BasePart in child:GetChildren() do
                if point:IsA("BasePart") then
					point.Transparency = 1
					table.insert(points, point)
				end
            end
            if #points < 2 then continue end

            table.sort(points, function(a, b)
                local cPoint = tonumber(a.Name)
                local nextPoint = tonumber(b.Name)

                if cPoint and nextPoint then return cPoint < nextPoint end

                return false
            end)

            --- render bezier curve
            local curvePoints = Bezier.new(unpack(points))
			curvePointsSet[child] = curvePoints

            local startOrb = Instance.new("Part")
            startOrb.Name = "StartOrb"
            startOrb.Anchored = true
            startOrb.Transparency = 1
            startOrb.Shape = Enum.PartType.Ball
            startOrb.Size = Vector3.one * 3.75
            startOrb.CFrame = points[1].CFrame
            startOrb.CanCollide = false
            startOrb.CanQuery = false
            startOrb.Parent = child
			Add(startOrb)

            local function _pointDistance()
                local total = 0
                for i = 1, #points - 1 do
                    total += (points[i].Position - points[i + 1].Position).Magnitude
                end

                return math.ceil(total * 2)
            end
            local interations = math.clamp(_pointDistance() / 5, 1, 100)
            local increment = 1/ interations
            local count = 0
            local segments = {} :: { BasePart }
            local segmentPoints = {}

            for i = increment, 1 + increment, increment do
                count += 1

                local segment = Instance.new("Part")
                segment.Anchored = true
                segment.CanCollide = false
                segment.CanQuery = false
                segment.Material = Enum.Material.Fabric
                segment.Color = Color3.new()

                segments[count] = segment
                table.insert(segmentPoints, curvePoints:CalculatePositionAt(i - increment))
            end
            table.insert(segmentPoints, curvePoints:CalculatePositionAt(1))

            local segmentCFrames = table.create(#segments)
            local totalSegmentLength = 0

            for i = 1, #segments do
                local start = segmentPoints[i]
                local endPoint = segmentPoints[i + 1]

                if start and endPoint then
                    local segmentCFrame = CFrame.new((start + endPoint) * 0.5, endPoint)
                    local segmentLength = (endPoint - start).Magnitude

                    segments[i].Size = Vector3.new(0.25, 0.25, segmentLength)
                    segments[i].Parent = child
					Add(segments[i])

                    totalSegmentLength += segmentLength
                    table.insert(segmentCFrames, segmentCFrame)
                else
                    table.insert(segmentCFrames, segments[i].CFrame)
                end
            end

            child:SetAttribute("TotalSegmentLength", totalSegmentLength)
            workspace:BulkMoveTo(segments, segmentCFrames, Enum.BulkMoveMode.FireCFrameChanged)
        end
    end
end
setupZipline()

local touchCD = false
Add(char.Humanoid.RootPart.Touched:Connect(function(hit: BasePart)
    if hit and hit.Parent
        and hit:IsA("BasePart")
        and hit.Name == "StartOrb"
        and hit.Parent:IsA("Model")
        and hit.Parent.Name == "Zipline" then

		if touchCD then return end
		touchCD = true
		Spawn(function()
			task.wait(0.5)
			touchCD = false
		end)

		if isRiding then return end
		isRiding = true

		--- run zipline
		local curvePoints = curvePointsSet[hit.Parent]
		curvePoints:UpdateLength()

		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.AutoRotate = false

		local sparklePart = Instance.new("Part")
		sparklePart.Name = "SparklePart"
		sparklePart.CanQuery = false
		sparklePart.CanTouch = false
		sparklePart.CanCollide = false
		sparklePart.Size = Vector3.one * 0.2
		sparklePart.Anchored = true
		sparklePart.Transparency = 1

		local sparkle = Instance.new("Sparkles")
		sparkle.SparkleColor = Color3.fromRGB(255, 179, 0)
		sparkle.Parent = sparklePart

		sparklePart.Parent = char

		local bp = Instance.new("BodyPosition")
		bp.Position = char.PrimaryPart.Position
		bp.MaxForce = Vector3.one * 10000
		bp.P = 10000
		bp.Parent = char.PrimaryPart

		local previousCF = CFrame.new()
		local curveT = 0
		local cancelRide = false

		while curveT <= 1 and task.wait() do
			if char.Humanoid.Health <= 0 then break end
			if cancelRide then break end

			local startMoving = tick()
			local rideTime = (1 / 60) / (hit.Parent:GetAttribute("TotalSegmentLength") / hit.Parent:GetAttribute("Speed"))

			local bezierPos = curvePoints:CalculatePositionRelativeToLength(curveT)
			while bezierPos ~= bezierPos do
				bezierPos = curvePoints:CalculatePositionRelativeToLength(curveT)
			end

			local nextBezierPos = curvePoints:CalculatePositionRelativeToLength(math.clamp(curveT + rideTime, 0, 1))
			if bezierPos == nextBezierPos then --- duplicated parts???
				nextBezierPos = previousCF.Rotation
			end

			local rideCFrame = if typeof(nextBezierPos) == "Vector3" then
				CFrame.new(bezierPos, nextBezierPos) else
				CFrame.new(bezierPos) * nextBezierPos

			previousCF = rideCFrame

			char.PrimaryPart.CFrame = rideCFrame * CFrame.new(0.1, -2.5, 0)
			char.PrimaryPart.Velocity = Vector3.zero

			bp.Position = char.PrimaryPart.Position
			if sparklePart then sparklePart.CFrame = rideCFrame end

			local timeTaken = tick() - startMoving
			local frameDt = RunService.RenderStepped:Wait()
			local scaleFrameDt = (timeTaken + frameDt) / (1 / 60)

			if curveT <= 1 then
				if curveT < 1 then
					curveT = math.clamp(curveT + rideTime * scaleFrameDt, 0, 1)
				else
					curveT += rideTime * scaleFrameDt
				end
			end
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		humanoid.AutoRotate = true

		if sparklePart then Debris:AddItem(sparklePart, 0.5) end
		if bp then bp:Destroy() end

		isRiding = false
		char.PrimaryPart.Velocity = char.PrimaryPart.CFrame:Inverse():VectorToObjectSpace(Vector3.new(0, 0, -hit.Parent:GetAttribute("Speed") * 1.45))
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
