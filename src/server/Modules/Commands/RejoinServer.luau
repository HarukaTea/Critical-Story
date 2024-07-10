--!nocheck

local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

return function (context)
    Signals.RejoinPlace:Fire(context.Executor)

    return "Attempt to rejoin..."
end
