--!nocheck

return {
    Name = "followplayer",
    Description = "Follow a player and then teleport to that server.",
    Group = "Moderators",
    Args = {
        {
            Type = "string",
            Name = "player",
            Description = "The player username you want to follow"
        }
    }
}
