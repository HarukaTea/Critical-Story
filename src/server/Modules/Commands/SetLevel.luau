--!strict

return {
    Name = "setlevel",
    Aliases = {"level"},
    Description = "Set the level whenever you want.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wish to apply"
        },
        {
            Type = "number",
            Name = "level",
            Description = "The level you wish to set"
        }
    }
}
