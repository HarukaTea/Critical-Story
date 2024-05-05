--!nocheck
--!optimize 2
--!native

return {
    Name = "clear",
    Description = "clear a player's backpack",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player you wanna clear"
        }
    }
}
