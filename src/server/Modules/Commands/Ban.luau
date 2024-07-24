--!nocheck

return {
    Name = "ban",
    Description = "Ban a player",
    Group = "Moderator",
    Args = {
        {
            Type = "string",
            Name = "player",
            Description = "The player's USERNAME you wanna ban"
        },
        {
            Type = "number",
            Name = "duration",
            Description = "The duration of ban, in SECONDS, -1 is permanent ban"
        },
        function(context: table)
            return {
                Type = context.Cmdr.Util.MakeEnumType("BanReason", {
                    "Cheating", "Offensive", "Farming", "Others"
                }),
                Name = "reason",
                Description = "The reason of this ban"
            }
        end
    }
}
