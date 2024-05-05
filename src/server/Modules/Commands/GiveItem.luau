--!nocheck
--!optimize 2
--!native

return {
    Name = "giveitem",
    Aliases = {"give"},
    Description = "Give the item which exist in game to a player.",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player who recieve this item"
        },
        {
            Type = "string",
            Name = "item",
            Description = "The item id of item, NOT the item name"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of this item",
            Default = 1
        }
    }
}
