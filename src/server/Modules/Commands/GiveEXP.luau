--!nocheck

return {
    Name = "giveexp",
    Aliases = { "exp" },
    Description = "Give the exp to which you given.",
    Group = "Testers",
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
