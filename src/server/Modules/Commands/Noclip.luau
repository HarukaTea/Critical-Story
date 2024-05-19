--!nocheck

return {
    Name = "noclip",
    Description = "give player noclip perm",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wanna give perm to",
            Default = "me"
        }
    }
}