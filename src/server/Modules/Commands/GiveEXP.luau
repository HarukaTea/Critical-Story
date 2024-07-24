--!nocheck

return {
    Name = "giveexp",
    Aliases = { "exp" },
    Description = "Give player(s) EXP",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The players you want to give"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of EXP you wish to get"
        }
    }
}
