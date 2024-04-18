--!nocheck
--!optimize 2
--!native

local ClientProcess = {}

local RunService = game:GetService("RunService")
local Util = script.Parent.Parent.Util

local Type = require(script.Parent.Parent.Type)
local Event = require(script.Parent.Parent.Event)
local Spawn = require(script.Parent.Parent.Parent.Parent.Spawn)
local Key = require(Util.Key)
local RateLimit = require(Util.RateLimit)

local clientRatelimit: Type.StoredRatelimit = {}
local clientQueue: Type.QueueMap = {}
local clientCallback: Type.CallbackMap = {}
local clientRequestQueue: Type.QueueMap = {}

local queueIn: {
	[string]: {any}
} = {}
local queueInRequest: {
	[number]: {
		[string]: {
			any
		}
	}
} = {}
local queueOutRequest: {
	[number]: {
		[string]: {
			any
		}
	}
} = {}
local incoming_cache: {
	[string]: {
		any
	}
} = {}

local insert, clear, remove, unpack, clone = table.insert, table.clear, table.remove, table.unpack, table.clone
local delay, spawn, cancel = task.delay, task.spawn, task.cancel
local clock = os.clock
local yield, isRunning = coroutine.yield, coroutine.running

queueInRequest[1] = {}
queueInRequest[2] = {}
queueOutRequest[1] = {}
queueOutRequest[2] = {}

local ReliableEvent = Event.Reliable
local RequestEvent = Event.Request

function ClientProcess.insertQueue(Identifier: string, ...: any)
	insert(clientQueue[Identifier], { ... })
end

function ClientProcess.insertRequest(Identifier: string, timeout: number, ...: any)
	local yieldThread: thread, start = isRunning(), clock()
	local cancelFunc = delay(timeout, function()
		spawn(yieldThread, nil)
	end)

	insert(clientRequestQueue[Identifier], { tostring(Key()), function(...: any)
		if (clock() - start) > timeout then return end

		cancel(cancelFunc)
		spawn(yieldThread, ...)
	end :: any, { ... } :: any })

	return yield()
end

function ClientProcess.add(Identifier: string, originId: string)
	if not clientQueue[Identifier] then
		clientRatelimit[Identifier] = RateLimit.create(originId)
		clientQueue[Identifier] = {}
		clientRequestQueue[Identifier] = {}
		clientCallback[Identifier] = {}

		queueOutRequest[1][Identifier] = {}
		queueOutRequest[2][Identifier] = {}
		queueInRequest[1][Identifier] = {}
		queueInRequest[2][Identifier] = {}
		queueIn[Identifier] = {}
	end
end

function ClientProcess.addCallback(Identifier: string, key: string, callback)
	clientCallback[Identifier][key] = callback
end

function ClientProcess.removeCallback(Identifier: string, key: string)
	clientCallback[Identifier][key] = nil
end

function ClientProcess.start()
	local function onPostSimulation()
		for Identifier: string, data: any in clientQueue do
			if #data > 0 then
				if clientRatelimit[Identifier](#data) then
					ReliableEvent:FireServer(Identifier, data)
				end
				clear(data)
			end

			if #clientRequestQueue[Identifier] > 0 then
				for _, requestData in clientRequestQueue[Identifier] do
					if not requestData[3] then continue end
					insert(queueOutRequest[1][Identifier], { requestData[1], requestData[3] })
					remove(requestData, #requestData)
				end
			end

			if incoming_cache[Identifier] then
				for _, packet in incoming_cache[Identifier] do
					if not queueIn[Identifier] then continue end
					insert(queueIn[Identifier], clone(packet))
					clear(incoming_cache[Identifier])
				end
			end

			if clientCallback[Identifier] then
				if #queueIn[Identifier] > 0 then
					for _, packedDatas: any in queueIn[Identifier] do
						if #packedDatas == 0 then continue end
						for _, v: any in packedDatas do
							for _, fn: any in clientCallback[Identifier] do
								Spawn(fn, unpack(v))
							end
						end
					end
					clear(queueIn[Identifier])
				end

				if #queueInRequest[1][Identifier] > 0 then
					for idx, packetDatas: any in queueInRequest[1][Identifier] do
						if #packetDatas == 0 then continue end

						for _, packetData in packetDatas do
							for _, fn: any in clientCallback[Identifier] do
								Spawn(function()
									local requestReturn = { fn(table.unpack(packetData[2])) }

									insert(queueOutRequest[2][Identifier], { packetData[1],  requestReturn })
								end)
							end
						end
					end
					clear(queueInRequest[1][Identifier])
				end

				if #queueInRequest[2][Identifier] > 0 then
					for _, packetDatas: any in queueInRequest[2][Identifier] do
						for _, packetData in packetDatas do
							if #packetData == 1 then continue end
							for idx, clientRequest in clientRequestQueue[Identifier] do
								if clientRequest[1] == packetData[1] then
									Spawn(clientRequest[2], unpack(packetData[2]))

									remove(clientRequestQueue[Identifier], idx)
									break
								end
							end
						end
					end
					clear(queueInRequest[2][Identifier])
				end
			end
		end

		for Identifier: string, requestsData in queueOutRequest[1] do
			if #requestsData == 0 then continue end

			RequestEvent:FireServer(Identifier, "\1", requestsData)
			clear(queueOutRequest[1][Identifier])
		end

		for Identifier: string, requestsData in queueOutRequest[2] do
			if #requestsData == 0 then continue end

			RequestEvent:FireServer(Identifier, "\0", requestsData)
			clear(queueOutRequest[2][Identifier])
		end
	end
	RunService.PostSimulation:Connect(onPostSimulation)

	local function onClientNetworkReceive(Identifier: string, data: any)
		if not Identifier or not data then return end
		if not queueIn[Identifier] then
			queueIn[Identifier] = {}
		end
		if not clientCallback[Identifier] then
			if not incoming_cache[Identifier] then
				incoming_cache[Identifier] = {}
			end

			insert(incoming_cache[Identifier], data)
			return
		end
		insert(queueIn[Identifier], data)
	end
	ReliableEvent.OnClientEvent:Connect(onClientNetworkReceive)

	local function onClientRequestReceive(Identifier: string, action: string, returnDatas)
		if not Identifier or not returnDatas then return end

		if action == "\1" then
			insert(queueInRequest[1][Identifier], returnDatas)
		else
			insert(queueInRequest[2][Identifier], returnDatas)
		end
	end
	RequestEvent.OnClientEvent:Connect(onClientRequestReceive)
end

return ClientProcess