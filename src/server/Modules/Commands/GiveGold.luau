--!nocheck

return {
    Name = "givegold",
    Aliases = { "gold" },
    Description = "Give gold for player(s)",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player you want to give"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of gold you wish to get, negative amount supported"
        }
    }
}
