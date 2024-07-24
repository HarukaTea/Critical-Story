--!nocheck

return {
    Name = "giverep",
    Aliases = { "rp" },
    Description = "Give reputation for player(s)",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player(s) you want to give"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of reputation you want to get, negative amount supported"
        }
    }
}
