--!native
--!strict
-- FastNet2
-- Author: @EternityDev (Eternity_Devs)
-- version rc9 (0.9.7)

local FastNet2 = {}
FastNet2.__index = FastNet2
FastNet2.version = 0.9

local IsServer: boolean = game:GetService("RunService"):IsServer()

if IsServer then
	if not script:FindFirstChild("Event") then
		Instance.new("RemoteEvent", script).Name = "Event"
	end
	if not script:FindFirstChild("UnreliableEvent") then
		Instance.new("UnreliableRemoteEvent", script).Name = "UnreliableEvent"
	end
else
	if not script:FindFirstChild("Event") or not script:FindFirstChild("UnreliableEvent") then
		warn("[FastNet2]: Waiting for initialize from server-side.")
		repeat
			task.wait()
		until script:FindFirstChild("Event") and script:FindFirstChild("UnreliableEvent")
	end
end

local Debug = require(script.Debug)
local Util = require(script.Util)

--[[**

	Create a Universal Unique Identifier (UUID)

**--]]

function FastNet2.CreateUUID(): string
	return Util.CreateUUID()
end

--[[**

	Receive all fastnet2 debug logs

	@returns all debugging logs

**--]]

function FastNet2.debugLogs(): { any }
	return Debug.receiveAll()
end

if IsServer then
	return setmetatable(FastNet2, require(script.Server))
end
return setmetatable(FastNet2, require(script.Client))
