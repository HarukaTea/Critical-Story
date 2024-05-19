--!nocheck

return {
    Name = "giverep",
    Aliases = { "rp" },
    Description = "Add the reputation to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player you want to set"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of reputation you want to get"
        }
    }
}
