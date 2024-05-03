--!nocheck
--!optimize 2
--!native

local TeleS = game:GetService("TeleportService")

return function (_, plr: Player)
    TeleS:Teleport(game.PlaceId, plr, plr:GetJoinData().TeleportData)

    return "Attempt to rejoin..."
end
