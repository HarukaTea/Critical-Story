--!nocheck

return {
    Name = "ban",
    Description = "Ban a player",
    Group = "Moderators",
    Args = {
        {
            Type = "string",
            Name = "player",
            Description = "The player's username you wanna ban"
        },
        {
            Type = "number",
            Name = "duration",
            Description = "The duration of ban, in SECONDS, -1 is permanent ban"
        },
        function(context: table)
            return {
                Type = context.Cmdr.Util.MakeEnumType("BanReason", {
                    "Cheating", "Offensive", "Other"
                }),
                Name = "reason",
                Description = "The reason of this ban"
            }
        end
    }
}
