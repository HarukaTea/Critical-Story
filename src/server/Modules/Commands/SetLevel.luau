--!nocheck

return {
    Name = "setlevel",
    Aliases = {"level"},
    Description = "Set the level of player(s)",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player(s) you want to apply"
        },
        {
            Type = "number",
            Name = "level",
            Description = "The level you want to set"
        }
    }
}
