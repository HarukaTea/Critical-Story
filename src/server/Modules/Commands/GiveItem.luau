--!strict
--!optimize 2
--!native

return {
    Name = "giveitem",
    Aliases = {"give"},
    Description = "Give the item which exist in game to a player.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wish to give"
        },
        {
            Type = "string",
            Name = "item",
            Description = "The item id of item, for example: HuntingDagger"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of this gift",
            Default = 1
        }
    }
}
