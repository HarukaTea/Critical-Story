--!strict
--!optimize 2
--!native

return {
    Name = "setrep",
    Aliases = {"rep"},
    Description = "Set the reputation amount to which you given.",
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
            Description = "The amount of reputation you wish to get"
        }
    }
}
