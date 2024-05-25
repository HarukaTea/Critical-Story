--!native
--!strict
--!optimize 2

local ClientProcess = {}

local RunService = game:GetService("RunService")

local Util = script.Parent.Parent.Util

local Event = require(script.Parent.Parent.Event)
local Spawn = require(Util.Spawn)
local RateLimit = require(Util.RateLimit)
local Buffer = require(Util.Buffer)

local clientRatelimit = {}
local clientQueue = {}
local unreliableClientQueue = {}
local clientCallback = {}
local clientRequestQueue = {}
local registeredIdentifier = {}

local queueIn = {}
local queueInRequest = {}
local queueOutRequest = {}

queueInRequest[1] = {}
queueInRequest[2] = {}
queueOutRequest[1] = {}
queueOutRequest[2] = {}

local ReliableEvent = Event.Reliable
local UnreliableEvent = Event.Unreliable

function ClientProcess.insertQueue(Identifier: string, reliable: boolean, ...: any)
	if not reliable then
		if not unreliableClientQueue[Identifier] then
			unreliableClientQueue[Identifier] = {}
		end
		table.insert(unreliableClientQueue[Identifier], { ... })
		return
	end
	if not clientQueue[Identifier] then
		clientQueue[Identifier] = {}
	end
	table.insert(clientQueue[Identifier], { ... })
end

function ClientProcess.add(Identifier: any, originId: string, conf: table)
	if not table.find(registeredIdentifier, Identifier) then
		table.insert(registeredIdentifier, Identifier)

		if not clientRatelimit[Identifier] then
			clientRatelimit[Identifier] = RateLimit.create(originId)
		end
		if not clientQueue[Identifier] then
			clientQueue[Identifier] = {}
		end
		if not unreliableClientQueue[Identifier] then
			unreliableClientQueue[Identifier] = {}
		end
		if not clientRequestQueue[Identifier] then
			clientRequestQueue[Identifier] = {}
		end
		if not clientCallback[Identifier] then
			clientCallback[Identifier] = {}
		end

		if not queueOutRequest[1][Identifier] then
			queueOutRequest[1][Identifier] = {}
		end
		if not queueOutRequest[2][Identifier] then
			queueOutRequest[2][Identifier] = {}
		end
		if not queueInRequest[1][Identifier] then
			queueInRequest[1][Identifier] = {}
		end
		if not queueInRequest[2][Identifier] then
			queueInRequest[2][Identifier] = {}
		end
		if not queueIn[Identifier] then
			queueIn[Identifier] = {}
		end
	end
end

function ClientProcess.addCallback(Identifier: string, key: string, callback)
	clientCallback[Identifier][key] = callback
end

function ClientProcess.removeCallback(Identifier: string, key: string)
	clientCallback[Identifier][key] = nil
end

function ClientProcess.start()
	debug.setmemorycategory("Warp")
	local clock_limit = 1/60
	local past_clock = os.clock()

	RunService.PostSimulation:Connect(function()
		if (os.clock()-past_clock) >= (clock_limit - 0.006) then -- less potential to skip frames
			past_clock = os.clock()

			-- Unreliable
			for Identifier: string, data: any in unreliableClientQueue do
				if #data == 0 then continue end
				if clientRatelimit[Identifier](#data) then
					UnreliableEvent:FireServer(Buffer.revert(Identifier), data)
				end
				unreliableClientQueue[Identifier] = nil
			end

			-- Reliable
			for Identifier: string, data: any in clientQueue do
				if #data > 0 then
					if clientRatelimit[Identifier](#data) then
						ReliableEvent:FireServer(Buffer.revert(Identifier), data)
					end
					clientQueue[Identifier] = nil
				end
			end
		end

		for _, Identifier: string in registeredIdentifier do
			if clientRequestQueue[Identifier] then
				for _, requestData in clientRequestQueue[Identifier] do
					if not requestData[3] then continue end
					if not queueOutRequest[1][Identifier] then
						queueOutRequest[1][Identifier] = {}
					end
					table.insert(queueOutRequest[1][Identifier], { requestData[1], requestData[3] })
				end
			end

			-- Unreliable & Reliable
			local callback = clientCallback[Identifier] or nil
			if not callback then continue end

			if queueIn[Identifier] then
				for _, packedDatas: any in queueIn[Identifier] do
					if #packedDatas == 0 then continue end
					for _, fn: any in callback do
						for i=1,#packedDatas do
							Spawn(fn, table.unpack(packedDatas[i] or {}))
						end
					end
				end
				queueIn[Identifier] = nil
			end

			-- Return Invoke
			if queueInRequest[1][Identifier] then
				for _, packetDatas: any in queueInRequest[1][Identifier] do
					if #packetDatas == 0 then continue end
					for _, fn: any in callback do
						for i=1,#packetDatas do
							if not packetDatas[i] then continue end
							local packetData1 = packetDatas[i][1]
							local packetData2 = packetDatas[i][2]
							Spawn(function()
								local requestReturn = { fn(table.unpack(packetData1)) }
								if not queueOutRequest[2][Identifier] then
									queueOutRequest[2][Identifier] = {}
								end
								table.insert(queueOutRequest[2][Identifier], { packetData2,  requestReturn })
								packetData1 = nil
								packetData2 = nil
							end)
						end
					end
				end
				queueInRequest[1][Identifier] = nil
			end

			-- Call to Invoke
			if queueInRequest[2][Identifier] then
				if clientRequestQueue[Identifier] then
					for _, packetDatas: any in queueInRequest[2][Identifier] do
						for _, packetData in packetDatas do
							if #packetData == 1 then continue end
							for y=1,#clientRequestQueue[Identifier] do
								local clientRequest = clientRequestQueue[Identifier][y]
								if not clientRequest then continue end
								if clientRequest[1] == packetData[1] then
									Spawn(clientRequest[2], table.unpack(packetData[2]))
									table.remove(clientRequestQueue[Identifier], y)
									break
								end
							end
						end
					end
				end
				queueInRequest[2][Identifier] = nil
			end
		end
	end)

	local function onClientNetworkReceive(Identifier: any, data: any)
		if not Identifier or not data then return end

		Identifier = Buffer.convert(Identifier)
		if not queueIn[Identifier] then
			queueIn[Identifier] = {}
		end
		table.insert(queueIn[Identifier], data)
	end
	ReliableEvent.OnClientEvent:Connect(onClientNetworkReceive)
	UnreliableEvent.OnClientEvent:Connect(onClientNetworkReceive)
end

return ClientProcess