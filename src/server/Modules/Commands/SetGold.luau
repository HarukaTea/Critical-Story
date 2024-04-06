--!strict
--!optimize 2
--!native

return {
    Name = "setgold",
    Aliases = {"gold"},
    Description = "Set the gold amount to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wish to set"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of gold you wish to get"
        }
    }
}
