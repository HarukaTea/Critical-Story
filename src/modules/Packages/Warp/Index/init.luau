--!nocheck

local Index = {}

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Server = script.Server
local Client = script.Client

local Type = require(script.Type)

if IsServer then
	require(Server.ServerProcess).start()
else
	require(Client.ClientProcess).start()
end

function Index.Server(Identifier: string, rateLimit: Type.rateLimitArg?): Type.Server
	return require(Server.Index)(Identifier, rateLimit) :: Type.Server
end
function Index.Client(Identifier: string): Type.Client
	return require(Client.Index)(Identifier) :: Type.Client
end

return table.freeze(Index) :: typeof(Index)
