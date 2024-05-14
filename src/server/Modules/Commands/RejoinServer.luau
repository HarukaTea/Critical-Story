--!nocheck
--!optimize 2
--!native

local TeleS = game:GetService("TeleportService")

return function (context)
    TeleS:Teleport(game.PlaceId, context.Executor)

    return "Attempt to rejoin..."
end
