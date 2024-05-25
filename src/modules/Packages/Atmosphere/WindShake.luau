--!nocheck

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VectorMap = require(ReplicatedStorage.Modules.Packages.DataLibs.VectorMap)

local COLLECTION_TAG = "WindShake"

local WindShake = {
	RenderDistance = 150,
	MaxRefreshRate = 1 / 60,

	ObjectMetadata = {},
	VectorMap = VectorMap.new(),

	Handled = 0,
	Active = 0,

	_partList = table.create(500),
	_cframeList = table.create(500),
}

export type WindShakeSettings = {
	WindDirection: Vector3?,
	WindSpeed: number?,
	WindPower: number?,
}

function WindShake:AddObjectShake(object: BasePart | Bone)
	if typeof(object) ~= "Instance" then
		return
	end
	if not object:IsA("BasePart") then
		return
	end

	local metadata = self.ObjectMetadata

	if metadata[object] then
		return
	else
		self.Handled += 1
	end

	metadata[object] = {
		ChunkKey = self.VectorMap:AddObject(object.Position, object),

		Seed = math.random(5000) * 0.32,
		Origin = object.CFrame,
		LastUpdate = os.clock(),
	}
end


function WindShake:Update(deltaTime: number)
	local active = 0

	local now = os.clock()
	local slowerDeltaTime = deltaTime * 3
	local step = math.min(1, deltaTime * 5)

	-- Reuse tables to avoid garbage collection
	local bulkMoveIndex = 0
	local partList = self._partList
	local cframeList = self._cframeList
	table.clear(partList)
	table.clear(cframeList)

	-- Cache hot values
	local objectMetadata = self.ObjectMetadata
	local camera = workspace.CurrentCamera
	local cameraPos = camera.CFrame.Position
	local renderDistance = self.RenderDistance
	local maxRefreshRate = self.MaxRefreshRate

	-- Update objects in view at their respective refresh rates
	self.VectorMap:ForEachObjectInView(camera, renderDistance, function(object: BasePart)
		local objMeta = objectMetadata[object]
		local lastUpdate = objMeta.LastUpdate or 0

		-- Determine if the object refresh rate
		local objectCFrame = object.CFrame
		local distanceAlpha = ((cameraPos - objectCFrame.Position).Magnitude / renderDistance)
		local distanceAlphaSq = distanceAlpha * distanceAlpha
		local jitter = (1 / math.random(60, 120))
		local refreshRate = (slowerDeltaTime * distanceAlphaSq) + maxRefreshRate

		if (now - lastUpdate) + jitter <= refreshRate then
			-- It is not yet time to update
			return
		end

		objMeta.LastUpdate = now
		active += 1

		local wdirection = script:GetAttribute("WindDirection")
		if wdirection.Magnitude < 1e-5 then
			return
		end

		local amp = script:GetAttribute("WindPower") * 0.2
		if script:GetAttribute("WindPower") * 0.2 < 1e-5 then
			return
		end

		local freq = now * (script:GetAttribute("WindSpeed") * 0.08)
		if freq < 1e-5 then
			return
		end

		local seed = objMeta.Seed
		local animValue = (math.noise(freq, 0, seed) + 0.4) * amp
		local lerpAlpha = math.clamp(step + distanceAlphaSq, 0.1, 0.5)
		local lowAmp = amp / 3

		local origin = objMeta.Origin * CFrame.identity
		local localWindDirection = origin:VectorToObjectSpace(wdirection)

		bulkMoveIndex += 1
		partList[bulkMoveIndex] = object
		cframeList[bulkMoveIndex] = objectCFrame:Lerp(
			(
				origin
				* CFrame.fromAxisAngle(localWindDirection:Cross(Vector3.yAxis), -animValue)
				* CFrame.Angles(
					math.noise(seed, 0, freq) * lowAmp,
					math.noise(seed, freq, 0) * lowAmp,
					math.noise(freq, seed, 0) * lowAmp
				)
				* CFrame.identity
			) + (wdirection * animValue * (amp * 2)),
			lerpAlpha
		)
	end)

	self.Active = active

	workspace:BulkMoveTo(partList, cframeList, Enum.BulkMoveMode.FireCFrameChanged)
end

function WindShake:Pause()
	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	self.Active = 0
	self.Running = false
end

function WindShake:Resume()
	if self.Running then
		return
	else
		self.Running = true
	end

	-- Connect updater
	self.UpdateConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
end

function WindShake:Init(config: { MatchWorkspaceWind: boolean? })
	if self.Initialized then
		return
	end
	for key: string, value: any in config do
		script:SetAttribute(key, value)
	end

	-- Clear any old stuff.
	self:Cleanup()
	self.Initialized = true

	for _, object in CollectionService:GetTagged(COLLECTION_TAG) do
		self:AddObjectShake(object)
	end

	-- Automatically start.
	self:Resume()
end

function WindShake:Cleanup()
	if not self.Initialized then
		return
	end

	self:Pause()

	if self.AddedConnection then
		self.AddedConnection:Disconnect()
		self.AddedConnection = nil
	end

	if self.RemovedConnection then
		self.RemovedConnection:Disconnect()
		self.RemovedConnection = nil
	end

	if self.WorkspaceWindConnection then
		self.WorkspaceWindConnection:Disconnect()
		self.WorkspaceWindConnection = nil
	end

	table.clear(self.ObjectMetadata)
	self.VectorMap:ClearAll()

	self.Handled = 0
	self.Active = 0
	self.Initialized = false
end

return WindShake
