--!nocheck
--!optimize 2
--!native

return {
    Name = "giverep",
    Aliases = {"rep"},
    Description = "Add the reputation to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you want to set"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of reputation you want to get"
        }
    }
}
