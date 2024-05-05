--!nocheck
--!optimize 2
--!native

return {
    Name = "givegold",
    Aliases = {"gold"},
    Description = "Give the gold to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player you want to give"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of gold you wish to get"
        }
    }
}
