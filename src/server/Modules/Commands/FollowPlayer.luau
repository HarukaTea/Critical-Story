--!nocheck

return {
    Name = "followplayer",
    Description = "Follow a player and then teleport to that server.",
    Group = "Moderator",
    Args = {
        {
            Type = "string",
            Name = "player",
            Description = "The player you want to follow, type USERNAME"
        }
    }
}
