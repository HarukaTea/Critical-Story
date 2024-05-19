--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ItemBook = require(RepS.Modules.Data.ItemBook)

return {
    Name = "giveitem",
    Aliases = { "give" },
    Description = "Give the item which exist in game to a player.",
    Group = "Testers",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player who recieve this item"
        },
        function(context: table)
            local items = { "all" }
            for _, item: table in ItemBook.Items do
                items[#items + 1] = item.ItemId
            end

            return {
                Type = context.Cmdr.Util.MakeEnumType("GameItemsLib", items),
                Name = "item",
                Description = "The item you wish to get"
            }
        end,
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of this item",
            Default = 1
        }
    }
}
