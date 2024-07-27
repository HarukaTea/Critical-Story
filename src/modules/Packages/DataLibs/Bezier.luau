--!nocheck

export type BezierPoint = {
	Type: string;
	Point: Vector3 | BasePart;
}

local Bezier = {}
Bezier.__index = Bezier


function B(n: number, i: number, t: number)
	local function fact(n: number): number
		if n == 0 then
			return 1
		else
			return n * fact(n - 1)
		end
	end

	return (fact(n) / (fact(i) * fact(n - i))) * t^(i) * (1 - t)^(n - i)
end


-- creates a new Bezier object with the given points added in order
function Bezier.new(...: Vector3 | BasePart)
	local self = setmetatable({}, Bezier)
	local args = {...}

	self.ClassName = "Bezier"

	self.Points = {}
	self.LengthIterations = 250
	self.LengthIndices = {}
	self.Length = nil
	self._connections = {}

	-- iterate through given arguments
	for _, p in pairs(args) do
		self:AddPoint(p, nil, false)
	end

	return self
end


-- adds a BezierPoint to the Bezier
-- a Vector3 BezierPoint is static, while a BasePart BezierPoint changes if the BasePart's position changes
function Bezier:AddPoint(p: Vector3 | BasePart, index: number?, updateLength: boolean?)
	local newPoint: BezierPoint = {
		Type = typeof(p) == "Vector3" and "StaicPoint" or "BasePartPoint";
		Point = p;
	}

	-- if point is a BasePartPoint, then watch for removal and changes
	if newPoint.Type == "BasePartPoint" then
		local connection, connection2

		-- changed connection
		connection = (p:: BasePart).Changed:Connect(function(prop)
			if prop == "Position" then
				self:UpdateLength()
			end
		end)

		-- deleted connection
		connection2 = (p:: BasePart).AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				local index = table.find(self.Points, newPoint)
				if index then
					table.remove(self.Points, index)
				end
				connection:Disconnect()
				connection:Disconnect()
			end
		end)

		-- check if there is a connection table for the basepart
		if not self._connections[p] then
			self._connections[p] = {}
		end

		-- add connections to connection table
		table.insert(self._connections[p], connection)
		table.insert(self._connections[p], connection2)
	end

	-- add to list of points
	if index and type(index) == "number" then
		table.insert(self.Points, index, newPoint)

	elseif not index then
		table.insert(self.Points, newPoint)
	end

	-- update bezier
	if updateLength then self:UpdateLength() end
end


-- returns a table with vector3 control points of the Bezier
function Bezier:GetAllPoints(): {Vector3}

	-- declarations
	local points = self.Points
	local numPoints = #points
	local v3Points = {}

	-- iterate through points
	for i = 1, numPoints do
		table.insert(v3Points, self:GetPoint(i))
	end

	-- return list of points
	return v3Points
end


-- gets the BezierPoint of the Bezier at the index
function Bezier:GetPoint(i: number): Vector3?
	local points = self.Points

	if points[i] then
		return typeof(points[i].Point) == "Vector3" and points[i].Point or points[i].Point.Position
	end
end


function Bezier:Destroy()
	for _, point in self.Points do
		if typeof(point.Point) == "Instance" and point.Point:IsA("BasePart") then
			for _, connection in pairs(self._connections[point.Point]) do
				if connection.Connected then
					connection:Disconnect()
				end
			end
			self._connections[point.Point] = nil
		end
	end

	table.clear(self.Points)
end

-- updates length of the Bezier
function Bezier:UpdateLength()
	-- important values
	local points = self:GetAllPoints()
	local iterations = self.LengthIterations

	-- check if points is less than 2 (need at least 2 points to calculate length)
	if #points < 2 then
		return 0, {{0, 0, 0}, {0, 0, 0}}
	end

	-- start iteration
	local l = 0
	local sums = {}
	for i = 1, iterations do
		local dldt = self:CalculateDerivativeAt((i - 1) / (iterations - 1))
		l += dldt.Magnitude * (1 / iterations)
		table.insert(sums, {((i - 1) / (iterations - 1)), l, dldt})
	end

	-- return length and sum table
	self.Length, self.LengthIndices = l, sums
end


-- returns the Vector3 point at the given t value (t must be between 0 and 1 to return an excpected value)
-- does not work if the bezier does not have any points attached to it
function Bezier:CalculatePositionAt(t: number): Vector3
	-- start algorithm to calculate position in bezier
	local points = self.Points
	local numPoints = #points

	-- check if there is at least 1 point
	if numPoints > 0 then

		-- important values
		local points = self:GetAllPoints()
		local n = #points


		-- get position at t
		local c_t do
			c_t = Vector3.new()
			for i = 1, n do
				local p_i = points[i]
				local B_nit = B(n - 1, i - 1, t)
				c_t += B_nit * p_i
			end
		end

		return c_t
	end
end


-- returns the Vector3 point at the given t value, where t is relative to the length of the Bezier curve
-- does not work if the bezier does not have any points attached to it
function Bezier:CalculatePositionRelativeToLength(t: number, length: number?, lengthIndices): Vector3
	-- start algorithm to calculate position in bezier
	local points = self.Points
	local numPoints = #points

	-- check if there is at least 1 point
	if numPoints > 0 then
		-- important values
		if length then
			self.Length = length
		end
		if lengthIndices then
			self.LengthIndices = lengthIndices
		end
		if not self.Length or #self.LengthIndices == 0 then
			self:UpdateLength()
		end

		local length = self.Length
		local LengthIndices = self.LengthIndices
		local points = self:GetAllPoints()

		-- check if there is more than 1 point
		if #points > 1 then

			-- get length of bezier
			local targetLength = length * t

			-- iterate through sum table
			local nearestParameterIndex, nearestParameter
			for i, orderedPair in ipairs(LengthIndices) do
				if targetLength - orderedPair[2] <= 0 then
					nearestParameterIndex = i
					nearestParameter = orderedPair
					break
				elseif i == #LengthIndices then
					nearestParameterIndex = i
					nearestParameter = orderedPair
					break
				end
			end

			-- calculate percent error
			local p0, p1
			if LengthIndices[nearestParameterIndex - 1] then
				p0, p1 = self:CalculatePositionAt(LengthIndices[nearestParameterIndex - 1][1]), self:CalculatePositionAt(nearestParameter[1])
			else
				p0, p1 = self:CalculatePositionAt(nearestParameter[1]), self:CalculatePositionAt(LengthIndices[nearestParameterIndex + 1][1])
			end
			local percentError = (nearestParameter[2] - targetLength) / (p1 - p0).Magnitude

			return p0 + (p1 - p0) * (1 - percentError)
		else
			return self:CalculatePositionAt(0)
		end
	end
end


-- returns the tangent vector in the direction of the path made by the bezier at t
-- in order to get a derivative of a Bezier, you need at least 2 points in the Bezier
function Bezier:CalculateDerivativeAt(t: number): Vector3?
	-- start algorithm to calculate bezier derivative
	local points = self.Points
	local numPoints = #points

	-- check if there are at least 2 points
	if numPoints > 1 then

		-- important values
		local points = self:GetAllPoints()
		local n = #points
		local m = n - 1

		-- calculate derivative at t
		local cPrime_t do
			cPrime_t = Vector3.new()
			for i = 1, n - 1 do
				local p_i1, p_i = points[i + 1], points[i]
				local Q_i = (n - 1) * (p_i1 - p_i)
				local B_mit = B(n - 2, i - 1, t)
				cPrime_t += B_mit * Q_i
			end
		end

		return cPrime_t
	end
end

return Bezier
