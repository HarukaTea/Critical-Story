--!nocheck

local slotStats = {
	Slot1 = {
		Stats = {
			Levels = 1,
			EXP = 0,
			Gold = 0,
			RP = 0,
			PlayTime = 0,

			Cosmetic = "None",
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

		QuestsV3 = {
			Main = 1,
			Side = {},
			Town = {}
		},

		GamepassOwned = {},
		Donation = 0,

		Guild = {
			Name = "",
			Tier = 1,
			GuildIcon = "",
			Infamy = 0
		},

		Inventory = {},
		ClassUnlocks = { Warrior = true },
		WorldUnlocks = { Mainworld = true },
	}
}
slotStats.Slot2 = slotStats.Slot1
slotStats.Slot3 = slotStats.Slot1

return slotStats
