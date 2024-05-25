--!nocheck

local VectorMap = {}
VectorMap.__index = VectorMap

function VectorMap.new(voxelSize: number?)
	return setmetatable({
		_voxelSize = voxelSize or 50,
		_voxels = {},
	}, VectorMap)
end

function VectorMap:AddObject(position: Vector3, object: any)
	local className = object.ClassName

	local voxelSize = self._voxelSize
	local voxelKey = Vector3.new(
		math.floor(position.X / voxelSize),
		math.floor(position.Y / voxelSize),
		math.floor(position.Z / voxelSize)
	)

	local voxel = self._voxels[voxelKey]

	if voxel == nil then
		self._voxels[voxelKey] = {
			[className] = { object },
		}
	elseif voxel[className] == nil then
		voxel[className] = { object }
	else
		table.insert(voxel[className], object)
	end

	return voxelKey
end

function VectorMap:ForEachObjectInView(camera: Camera, distance: number, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local cameraCFrame = camera.CFrame
	local cameraPos = cameraCFrame.Position
	local rightVec, upVec = cameraCFrame.RightVector, cameraCFrame.UpVector

	local distance2 = distance / 2
	local farPlaneHeight2 = math.tan(math.rad((camera.FieldOfView + 5) / 2)) * distance
	local farPlaneWidth2 = farPlaneHeight2 * (camera.ViewportSize.X / camera.ViewportSize.Y)
	local farPlaneCFrame = cameraCFrame * CFrame.new(0, 0, -distance)
	local farPlaneTopLeft = farPlaneCFrame * Vector3.new(-farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneTopRight = farPlaneCFrame * Vector3.new(farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneBottomLeft = farPlaneCFrame * Vector3.new(-farPlaneWidth2, -farPlaneHeight2, 0)
	local farPlaneBottomRight = farPlaneCFrame * Vector3.new(farPlaneWidth2, -farPlaneHeight2, 0)

	local frustumCFrameInverse = (cameraCFrame * CFrame.new(0, 0, -distance2)):Inverse()

	local rightNormal = upVec:Cross(farPlaneBottomRight - cameraPos).Unit
	local leftNormal = upVec:Cross(farPlaneBottomLeft - cameraPos).Unit
	local topNormal = rightVec:Cross(cameraPos - farPlaneTopRight).Unit
	local bottomNormal = rightVec:Cross(cameraPos - farPlaneBottomRight).Unit

	local minBound =
		cameraPos:Min(farPlaneTopLeft):Min(farPlaneTopRight):Min(farPlaneBottomLeft):Min(farPlaneBottomRight)
	local maxBound =
		cameraPos:Max(farPlaneTopLeft):Max(farPlaneTopRight):Max(farPlaneBottomLeft):Max(farPlaneBottomRight)

	minBound = Vector3.new(
		math.floor(minBound.X / voxelSize),
		math.floor(minBound.Y / voxelSize),
		math.floor(minBound.Z / voxelSize)
	)
	maxBound = Vector3.new(
		math.floor(maxBound.X / voxelSize),
		math.floor(maxBound.Y / voxelSize),
		math.floor(maxBound.Z / voxelSize)
	)

	local function isPointInView(point: Vector3): boolean
		-- Check if point lies outside frustum OBB
		local relativeToOBB = frustumCFrameInverse * point
		if
			relativeToOBB.X > farPlaneWidth2
			or relativeToOBB.X < -farPlaneWidth2
			or relativeToOBB.Y > farPlaneHeight2
			or relativeToOBB.Y < -farPlaneHeight2
			or relativeToOBB.Z > distance2
			or relativeToOBB.Z < -distance2
		then
			return false
		end

		-- Check if point lies outside a frustum plane
		local lookToCell = point - cameraPos
		if
			rightNormal:Dot(lookToCell) < 0
			or leftNormal:Dot(lookToCell) > 0
			or topNormal:Dot(lookToCell) < 0
			or bottomNormal:Dot(lookToCell) > 0
		then
			return false
		end

		return true
	end

	for x = minBound.X, maxBound.X do
		local xMin = x * voxelSize
		local xMax = xMin + voxelSize
		local xPos = math.clamp(farPlaneCFrame.X, xMin, xMax)

		for y = minBound.Y, maxBound.Y do
			local yMin = y * voxelSize
			local yMax = yMin + voxelSize
			local yPos = math.clamp(farPlaneCFrame.Y, yMin, yMax)

			for z = minBound.Z, maxBound.Z do
				local zMin = z * voxelSize
				local zMax = zMin + voxelSize

				local voxelNearestPoint = Vector3.new(xPos, yPos, math.clamp(farPlaneCFrame.Z, zMin, zMax))
				if isPointInView(voxelNearestPoint) then
					-- Found the first in frustum, now binary search for the last
					local entry, exit = z, minBound.Z - 1
					local left = z
					local right = maxBound.Z

					while left <= right do
						local mid = math.floor((left + right) / 2)
						local midPos = Vector3.new(
							xPos,
							yPos,
							math.clamp(farPlaneCFrame.Z, mid * voxelSize, mid * voxelSize + voxelSize)
						)

						if isPointInView(midPos) then
							exit = mid
							left = mid + 1
						else
							right = mid - 1
						end
					end

					for fillZ = entry, exit do
						local voxel = self._voxels[Vector3.new(x, y, fillZ)]
						if voxel then
							for _, objects in voxel do
								for _, object in objects do callback(object) end
							end
						end
					end

					break
				end
			end
		end
	end
end

function VectorMap:ClearAll()
	self._voxels = {}
end

return VectorMap
