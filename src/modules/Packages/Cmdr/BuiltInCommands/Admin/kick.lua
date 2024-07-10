return {
	Name = "kick",
	Aliases = { "boot" },
	Description = "Kicks a player or set of players.",
	Group = "Moderators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to kick.",
		},
	},
}
