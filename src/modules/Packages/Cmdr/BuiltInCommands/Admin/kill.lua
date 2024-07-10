return {
	Name = "kill",
	Aliases = { "slay" },
	Description = "Kills a player or set of players.",
	Group = "Moderators",
	Args = {
		{
			Type = "players",
			Name = "victims",
			Description = "The players to kill.",
		},
	},
}
