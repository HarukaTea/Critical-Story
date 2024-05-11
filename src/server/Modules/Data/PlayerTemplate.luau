--!nocheck
--!optimize 2
--!native

return {
    Stats = {
		Levels = 1,
		EXP = 0,
		Gold = 0,
		RP = 0,
		PlayTime = 0,

		Class = "Warrior",
		LastSeenLocation = "InitusBay",
		LastLeave = { "Vector3", 0, 0, 0 },

		LvPoints = 0,
		DMGPoints = 0,
		MagicPoints = 0,
		ManaPoints = 0,
		ShieldPoints = 0,
		HealthPoints = 0,
	},

	Inventory = {},
	Quests = {
		Main = 1,
		Town = {}
	},

	Settings = {
		Musics = true,
		SFXs = true,
		PotatoMode = false,
		PlayerList = true,
		MapDetails = true,
		CombatMode = "Solo"
	}
}
