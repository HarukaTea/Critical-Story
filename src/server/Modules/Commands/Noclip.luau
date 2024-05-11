--!nocheck
--!optimize 2
--!native

return {
    Name = "noclip",
    Description = "give player noclip perm",
    Group = "Moderators",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wanna give perm to",
            Default = "me"
        }
    }
}