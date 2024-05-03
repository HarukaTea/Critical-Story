--!nocheck
--!optimize 2
--!native

return {
    Name = "rejoin",
    Description = "Rejoin the game",
    Group = "Players",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player who rejoin",
            Default = "me"
        }
    }
}
