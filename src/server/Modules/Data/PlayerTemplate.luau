--!nocheck

local slotStats = {
	Slot1 = {
		Stats = {
			Levels = 1,
			EXP = 0,
			Gold = 0,
			RP = 0,
			PlayTime = 0,

			Class = "Warrior",
			LastSeenLocation = "MonolithVillage",
			LastSeenWorld = "Mainworld",

			LvPoints = 0,
			DMGPoints = 0,
			MagicPoints = 0,
			ManaPoints = 0,
			HealthPoints = 0
		},

		Quests = {
			Main = 1,
			Side = {},
			Town = {}
		},

		Settings = {
			Musics = true,
			SFXs = true,
			PotatoMode = false,
			PlayerList = true,
			MapDetails = true,
			CombatMode = "Solo",
			Particles = true
		},

		Inventory = {},
	}
}
slotStats.Slot2 = slotStats.Slot1
slotStats.Slot3 = slotStats.Slot1

return slotStats
