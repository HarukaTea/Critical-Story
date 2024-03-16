--!strict

return {
    Stats = {
		Levels = 1,
		EXP = 0,
		Gold = 0,
		RP = 0,
		PlayTime = 0,

		Class = "Warrior",
		LastSeenLocation = "InitusVillage",

		LvPoints = 0,
		DmgPoints = 0,
		MagicPoints = 0,
		ManaPoints = 0,
		HealthPoints = 0,
		ShieldPoints = 0,

		LastLeave = { "Vector3", 0, 0, 0 }
	},

	Inventory = {},
	EquippedItems = {},
	PinnedItems = {},

	Quests = {
		Main = 1,
		Town = {}
	},

	Settings = {
		Musics = true,
		SFXs = true,
		PotatoMode = false,
		PlayerList = true,
		InviteAccess = true,
		CombatMode = "Solo"
	}
}
