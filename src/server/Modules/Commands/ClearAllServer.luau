--!nocheck

return function (_, players: table)
    for _, plr: Player in players do
        if not plr then continue end

        plr.Inventory:ClearAllChildren()
    end

    return "Cleared!"
end
