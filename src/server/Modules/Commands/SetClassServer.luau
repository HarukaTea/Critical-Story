--!nocheck

return function (_, players: table, class: string)
    for _, plr: Player in players do
        plr:SetAttribute("Class", class)
        plr:SetAttribute("CLASS_UNLOCK_"..class, true)
    end

    return "Class has set to "..class.."!"
end
