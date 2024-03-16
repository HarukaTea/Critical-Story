--!strict

local ServerProcess = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Util = script.Parent.Parent.Util

local Type = require(script.Parent.Parent.Type)
local Event = require(script.Parent.Parent.Event)
local Spawn = require(script.Parent.Parent.Parent.Parent.Spawn)
local Key = require(Util.Key)
local RateLimit = require(Util.RateLimit)

local serverQueue: Type.QueueMap = {}
local serverCallback: Type.CallbackMap = {}
local serverRequestQueue: Type.QueueMap = {}

local queueOut: {
	[Player]: {
		[string]: {any},
	}
} = {}
local queueIn: {
	[string]: {
		[Player]: {any},
	}
} = {}
local queueInRequest: {
	[number]: {
		[string]: {
			[Player]: {any}
		}
	}
} = {}
local queueOutRequest: {
	[number]: {
		[string]: {
			[Player]: {any}
		}
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

local function initializeEachPlayer(player: Player)
	if not player then return end
	if not queueOut[player] then
		queueOut[player] = {}
	end
	for Identifier: string,_ in serverQueue do
		if not queueOut[player][Identifier] then
			queueOut[player][Identifier] = {}
		end
		if not serverRequestQueue[Identifier][player] then
			serverRequestQueue[Identifier][player] = {}
		end
		if not queueIn[Identifier][player] then
			queueIn[Identifier][player] = {}
		end
		if not queueInRequest[1][Identifier][player] then
			queueInRequest[1][Identifier][player] = {}
			queueInRequest[2][Identifier][player] = {}
		end
		if not queueOutRequest[1][Identifier][player] then
			queueOutRequest[1][Identifier][player] = {}
			queueOutRequest[2][Identifier][player] = {}
		end
	end
end
Players.PlayerAdded:Connect(initializeEachPlayer)

function ServerProcess.insertQueue(Identifier: string, player: Player, ...: any)
	if not serverQueue[Identifier][player] then
		serverQueue[Identifier][player] = {}
	end

	insert(serverQueue[Identifier][player], { ... })
end

function ServerProcess.insertRequest(Identifier: string, timeout: number, player: Player, ...: any)
	if not serverQueue[Identifier][player] then
		serverQueue[Identifier][player] = {}
	end

	local yieldThread: thread, start = isRunning(), clock()
	local cancelFunc = delay(timeout, function()
		spawn(yieldThread, nil)
	end)

	insert(serverRequestQueue[Identifier][player], { tostring(Key()), function(...: any)
		if (clock() - start) > timeout then return end

		cancel(cancelFunc)
		spawn(yieldThread, ...)
	end :: any, { ... } :: any })

	return yield()
end

function ServerProcess.add(Identifier: string, originId: string, ratelimit: Type.rateLimitArg)
	if not serverQueue[Identifier] then
		RateLimit.create(originId, ratelimit.maxEntrance or 200, ratelimit.interval or 2)

		serverQueue[Identifier] = {}
		serverCallback[Identifier] = {}
		serverRequestQueue[Identifier] = {}

		queueIn[Identifier] = {}
		queueInRequest[1][Identifier] = {}
		queueInRequest[2][Identifier] = {}
		queueOutRequest[1][Identifier] = {}
		queueOutRequest[2][Identifier] = {}

		for _, player: Player in ipairs(Players:GetPlayers()) do
			spawn(initializeEachPlayer, player)
		end
	end
end

function ServerProcess.addCallback(Identifier: string, key: string, callback)
	serverCallback[Identifier][key] = callback
end

function ServerProcess.removeCallback(Identifier: string, key: string)
	serverCallback[Identifier][key] = nil
end

function ServerProcess.start()
	local function onPostSimulation()
		for _, player: Player in ipairs(Players:GetPlayers()) do
			if not queueOut[player] then continue end

			for Identifier: string, data: any in queueOut[player] do
				if #data == 0 then continue end

				ReliableEvent:FireClient(player, Identifier, data)
				clear(data)
			end
		end

		for Identifier: string, players in serverQueue do
			for player: Player, data in players do
				if #data > 0 and queueOut[player] then
					queueOut[player][Identifier] = clone(data)
					clear(data)
				end

				if #serverRequestQueue[Identifier][player] > 0 then
					for _, requestData in serverRequestQueue[Identifier][player] do
						if not requestData[3] then continue end

						insert(queueOutRequest[1][Identifier][player], { requestData[1], requestData[3] })
						remove(requestData, #requestData)
					end
				end

				if serverCallback[Identifier] then
					if #queueIn[Identifier][player] > 0 then
						for _, packedDatas: any in queueIn[Identifier][player] do
							if #packedDatas == 0 then continue end
							for _, v: any in packedDatas do
								for _, fn: any in serverCallback[Identifier] do
									Spawn(fn, player, unpack(v))
								end
							end
						end
						clear(queueIn[Identifier][player])
					end

					if #queueInRequest[1][Identifier][player] > 0 then
						for idx, packetDatas: any in queueInRequest[1][Identifier][player] do
							if #packetDatas == 0 then continue end
							for _, packetData in packetDatas do
								for _, fn: any in serverCallback[Identifier] do
									Spawn(function()
										local requestReturn = { fn(player, unpack(packetData[2])) }
										insert(queueOutRequest[2][Identifier][player], { packetData[1], requestReturn })
									end)
								end
							end
						end
						clear(queueInRequest[1][Identifier][player])
					end

					if #queueInRequest[2][Identifier][player] > 0 then
						for _, packetDatas: any in queueInRequest[2][Identifier][player] do
							for _, packetData in packetDatas do
								if #packetData == 1 then continue end
								for idx, serverRequest in serverRequestQueue[Identifier][player] do
									if serverRequest[1] == packetData[1] then
										Spawn(serverRequest[2], unpack(packetData[2]))
										remove(serverRequestQueue[Identifier], idx)
										break
									end
								end
							end
						end
						clear(queueInRequest[2][Identifier][player])
					end

					for plr: Player, requestsData: any in queueOutRequest[1][Identifier] do
						if #requestsData == 0 then continue end

						RequestEvent:FireClient(plr, Identifier, "\1", requestsData)
						clear(requestsData)
					end
					for plr: Player, toReturnDatas: any in queueOutRequest[2][Identifier] do
						if #toReturnDatas == 0 then continue end

						RequestEvent:FireClient(plr, Identifier, "\0", toReturnDatas)
						clear(toReturnDatas)
					end
				end
			end
		end
	end
	RunService.PostSimulation:Connect(onPostSimulation)

	local function onServerNetworkReceive(player: Player, Identifier: string, data: any)
		if not Identifier or not data then return end
		if not serverQueue[Identifier] then
			serverQueue[Identifier] = {}
		end
		if not serverQueue[Identifier][player] then
			serverQueue[Identifier][player] = {}
		end
		if not queueIn[Identifier][player] then
			queueIn[Identifier][player] = {}
		end
		insert(queueIn[Identifier][player], data)
	end
	ReliableEvent.OnServerEvent:Connect(onServerNetworkReceive)

	local function onServerRequestReceive(player: Player, Identifier: string, action: string, data: any)
		if not Identifier or not data then return end
		if not queueInRequest[1][Identifier][player] then
			queueInRequest[1][Identifier][player] = {}
			queueInRequest[2][Identifier][player] = {}
		end
		if not serverQueue[Identifier][player] then
			serverQueue[Identifier][player] = {}
		end
		if action == "\1" then
			insert(queueInRequest[1][Identifier][player], data)
		else
			insert(queueInRequest[2][Identifier][player], data)
		end
	end
	RequestEvent.OnServerEvent:Connect(onServerRequestReceive)
end

for _, player: Player in ipairs(Players:GetPlayers()) do
	spawn(initializeEachPlayer, player)
end

return ServerProcess
