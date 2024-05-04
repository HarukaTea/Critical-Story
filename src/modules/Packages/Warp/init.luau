--!nocheck
--!optimize 2
--!native

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Server = script.Server
local Client = script.Client

if IsServer then
	require(Server.ServerProcess).start()

	return require(Server.Index)
else
	require(Client.ClientProcess).start()

	return require(Client.Index)
end
