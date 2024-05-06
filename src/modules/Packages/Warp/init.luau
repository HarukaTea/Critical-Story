--!strict
--!native
--!optimize 2

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Util = script.Util
local Server = script.Server
local Client = script.Client

local Type = require(script.Type)
local Assert = require(Util.Assert)

local function ServerCheck(isReliable: boolean, Identifier: string, conf: Type.ServerConf?): Type.Server
	Assert(IsServer, `[Warp]: Calling .Server({Identifier}) on client side (expected server side)`)
	Assert(typeof(Identifier) == "string", `[Warp]: Identifier must be a string type, got {typeof(Identifier)}`)

	return require(Server.Index)(isReliable, Identifier, conf) :: Type.Server
end
local function ClientCheck(isReliable: boolean, Identifier: string, conf: Type.ClientConf?): Type.Client
	Assert(not IsServer, `[Warp]: Calling .Client({Identifier}) on server side (expected client side)`)
	Assert(typeof(Identifier) == "string", `[Warp]: Identifier must be a string type, got {typeof(Identifier)}`)

	return require(Client.Index)(isReliable, Identifier, conf) :: Type.Client
end

if IsServer then
	require(Server.ServerProcess).start()

	return ServerCheck
else
	require(Client.ClientProcess).start()

	return ClientCheck
end
