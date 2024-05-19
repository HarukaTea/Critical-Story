--!nocheck

return {
    Name = "setlevel",
    Aliases = {"level"},
    Description = "Set the level to what you want.",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player you want to apply"
        },
        {
            Type = "number",
            Name = "level",
            Description = "The level you want to set"
        }
    }
}
