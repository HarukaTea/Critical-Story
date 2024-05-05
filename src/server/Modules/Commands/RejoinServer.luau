--!nocheck
--!optimize 2
--!native

local TeleS = game:GetService("TeleportService")

return function (context)
    TeleS:Teleport(7523159032, context.Executor)

    return "Attempt to rejoin..."
end
