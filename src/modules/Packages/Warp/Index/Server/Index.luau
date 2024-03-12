--!nocheck

local Server = {}
Server.__index = Server

local Players = game:GetService("Players")

local Util = script.Parent.Parent.Util

local Type = require(script.Parent.Parent.Type)
local ServerProcess = require(script.Parent.ServerProcess)
local Key = require(Util.Key)
local Serdes = require(Util.Serdes)

local insert, remove = table.insert, table.remove
local spawn = task.spawn
local isRunning, yield, clock = coroutine.running, coroutine.yield, os.clock

function Server.new(Identifier: string, rateLimit: Type.rateLimitArg?)
	local self = setmetatable({}, Server)
	self.id = Serdes(Identifier)
	self.fn = {}

	ServerProcess.add(self.id, Identifier, rateLimit or { maxEntrance = 200, interval = 2 })

	return self
end

function Server:Fire(player: Player, ...: any)
	ServerProcess.insertQueue(self.id, player, ...)
end

function Server:Fires(...: any)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		ServerProcess.insertQueue(self.id, player, ...)
	end
end

function Server:Invoke(timeout: number, player: Player, ...: any): any
	return ServerProcess.insertRequest(self.id, timeout, player, ...)
end

function Server:Connect(callback: (plyer: Player, args: any) -> ()): string
	local key = tostring(Key())

	insert(self.fn, key)
	ServerProcess.addCallback(self.id, key, callback)

	return key
end

function Server:Once(callback: (plyer: Player, args: any) -> ()): string
	local key = tostring(Key())

	insert(self.fn, key)
	ServerProcess.addCallback(self.id, key, function(...)
		self:Disconnect(key)

		spawn(callback, ...)
	end)

	return key
end

function Server:Wait()
	local thread: thread, t = isRunning(), clock()

	self:Once(function()
		spawn(thread, clock() - t)
	end)
	return yield()
end

function Server:DisconnectAll()
	for idx, key: string in self.fn do
		ServerProcess.removeCallback(self.id, key)

		remove(self.fn, idx)
	end
end

function Server:Disconnect(key: string)
	assert(typeof(key) == "string", "Key must be a string type.")

	ServerProcess.removeCallback(self.id, key)
end

function Server:Destroy()
	self:DisconnectAll()

	setmetatable(self, nil)
end

return Server.new