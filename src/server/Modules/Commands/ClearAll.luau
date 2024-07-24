--!nocheck

return {
    Name = "clear",
    Description = "Clear a player's backpack",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player(s) you wanna clear"
        }
    }
}
