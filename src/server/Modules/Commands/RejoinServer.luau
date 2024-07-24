--!nocheck

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

return function (context)
    local players = Players:GetPlayers()

    if #players <= 1 then return "Solo server, cannot rejoin." end

    Signals.RejoinPlace:Fire(context.Executor)

    return "Attempt to rejoin..."
end
