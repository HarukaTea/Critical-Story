--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ItemBook = require(RepS.Modules.Data.ItemBook)

return {
    Name = "giveitem",
    Aliases = { "give" },
    Description = "Give a item, which exist in game, for player(s).",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "Player(s) who recieve this item"
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
            Description = "The amount of this item, default is 1",
            Default = 1
        }
    }
}
