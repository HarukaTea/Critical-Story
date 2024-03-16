--!strict

local Client = {}
Client.__index = Client

local Util = script.Parent.Parent.Util

local ClientProcess = require(script.Parent.ClientProcess)
local Key = require(Util.Key)
local Serdes = require(Util.Serdes)

local insert, remove = table.insert, table.remove
local spawn = task.spawn
local clock = os.clock
local yield, isRunning = coroutine.yield, coroutine.running

function Client.new(Identifier: string)
	local self = setmetatable({}, Client)
	self.id = Serdes(Identifier)
	self.fn = {}

	ClientProcess.add(self.id, Identifier)

	return self
end

function Client:Fire(...: any)
	ClientProcess.insertQueue(self.id, ...)
end

function Client:Invoke(timeout: number, ...: any): any
	return ClientProcess.insertRequest(self.id, timeout, ...)
end

function Client:Connect(callback: (args: any) -> ()): string
	local key = tostring(Key())
	insert(self.fn, key)

	ClientProcess.addCallback(self.id, key, callback)
	return key
end

function Client:Once(callback: (args: any) -> ()): string
	local key = tostring(Key())
	insert(self.fn, key)

	ClientProcess.addCallback(self.id, key, function(...)
		self:Disconnect(key)

		spawn(callback, ...)
	end)
	return key
end

function Client:Wait()
	local thread: thread, t = isRunning(), clock()

	self:Once(function()
		spawn(thread, clock() - t)
	end)
	return yield()
end

function Client:DisconnectAll()
	for idx, key: string in self.fn do
		ClientProcess.removeCallback(self.id, key)

		remove(self.fn, idx)
	end
end

function Client:Disconnect(key: string)
	assert(typeof(key) == "string", "Key must be a string type.")

	ClientProcess.removeCallback(self.id, key)
end

function Client:Destroy()
	self:DisconnectAll()

	setmetatable(self, nil)
end

return Client.new
