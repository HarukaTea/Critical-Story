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
			HealthPoints = 0,
			ShieldPoints = 0
		},

		Quests = {
			Main = 1,
			Side = {},
			Town = {}
		},

		Inventory = {},
		ClassUnlocks = { Warrior = true },
		WorldUnlocks = { Mainworld = true },
	}
}
slotStats.Slot2 = slotStats.Slot1
slotStats.Slot3 = slotStats.Slot1

return slotStats
