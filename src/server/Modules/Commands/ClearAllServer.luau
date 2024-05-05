--!nocheck
--!optimize 2
--!native

return function (_, players: table)
    for _, plr: Player in players do
        plr.Inventory:ClearAllChildren()
    end

    return "Cleared!"
end
