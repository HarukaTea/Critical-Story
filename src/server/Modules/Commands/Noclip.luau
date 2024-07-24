--!nocheck

return {
    Name = "noclip",
    Description = "Noclip tool",
    Group = "Developer",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wish to give, default is you",
            Default = "me"
        }
    }
}