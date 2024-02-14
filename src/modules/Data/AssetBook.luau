--!nocheck

local assets = {}

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

assets.TweenInfos = {
	fourHalf = newTweenInfo(0.05),
	threeHalf = newTweenInfo(0.15),
	twiceHalf = newTweenInfo(0.2),
	onceHalf = newTweenInfo(0.3),
	half = newTweenInfo(0.5),
	halfBack = newTweenInfo(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = newTweenInfo(0.75),
	threeHalfOne = newTweenInfo(0.9),
	one = newTweenInfo(1),
	oneHalf = newTweenInfo(1.5),
	two = newTweenInfo(2),
	six = newTweenInfo(6)
}
assets.TierColor = {
	Common = fromRGB(0, 255, 0),
	Rare = fromRGB(49, 226, 236),
	Epic = fromRGB(214, 96, 253),
	Ultra = fromRGB(250, 250, 65),
	Mythic = fromRGB(255, 22, 57),
}
assets.TypeColor = {
	Active = fromRGB(255, 170, 127),
	Passive = fromRGB(99, 244, 9),
	Material = fromRGB(0, 222, 238),
	Cosmetic = fromRGB(170, 85, 255),
	Companion = fromRGB(255, 255, 255),
}
assets.ClassInfo = {
	Warrior = {
		Desc = "Hit orb to gain combo, the more combos you get, the more damage you deal with.",
		Image = "rbxassetid://2965862892",
		Color = fromRGB(255, 100, 100)
	},
	Archer = {
		Desc = "Hit orb to generate an arrow orb, which can increase the amount of arrows. Arrows can deal additional damage to monsters, which is calculated separately.",
		Image = "rbxassetid://2965863905",
		Color = fromRGB(100, 255, 100)
	},
	Wizard = {
		Desc = "Hit orb to charge, the magic ball will be casted when it's done.",
		Image = "rbxassetid://2965863231",
		Color = fromRGB(100, 100, 254)
	},
	Knight = {
		Desc = "Hit orb to gain defense, which can be used to mitigate the damage you receive.",
		Image = "rbxassetid://2965863677",
		Color = fromRGB(255, 255, 50)
	},
	Rogue = {
		Desc = "Hit orb to increase critical chance. Each critical hit is independently calculated as an additional chance.",
		Image = "rbxassetid://12284961892",
		Color = fromRGB(255, 170, 255)
	},
	Repeater = {
		Desc = "Hit orb to generate another orb within the combat area. However, this orb cannot generate orbs any more.",
		Image = "rbxassetid://12190533959",
		Color = fromRGB(65, 179, 255)
	},
	Striker = {
		Desc = "Hit orb to dash to the nearest orb, you can only dash when there is more than 1 orb.",
		Image = "rbxassetid://12190535870",
		Color = fromRGB(253, 148, 44)
	},
	Alchemist = {
		Desc = "Hit orbs of various colors to reach different research stages. Each stage will provide different effects. Red adds 1, Blue adds 2, and Green adds 3.",
		Image = "rbxassetid://12236618949",
		Color = fromRGB(0, 255, 22)
	},
	Illusionist = {
		Desc = "Hit orb to create your clone, which will cast all your actives equipped if you have enough Mana.",
		Image = "rbxassetid://15875390788",
		Color = fromRGB(0, 255, 252)
	}
}
assets.MonsterAvatars = {
	["Spike Fox"] = "rbxassetid://13886503379",
	["Spike Wolf"] = "rbxassetid://15688333529",
	["Green Slime"] = "rbxassetid://15951815518"
}

assets.LocationInfo = {
	Name = {
		InitusBay = "Initus Bay",
		FoxForest = "The Whispering Forest",
		SecretCave = "A Secret Cave",
		PrimisField = "Primis Field",
		SonusCave = "Sonus Cave"
	},

	Desc = {
		InitusBay = "The start of every adventure...",
		FoxForest = "A quiet forest, full of foxes...",
		SecretCave = "An unknown cave, usually used for testing...",
		PrimisField = "Familiar field, with the memory of Slimes...",
		SonusCave = "A pretty safe cave without bats..."
	}
}

assets.Items = {
	ItemCost = {},

	ItemName = {
		HealthyApple = "Healthy Apple",
		GoldenApple = "Golden Apple",
		FireballScroll = "Fireball Scroll",

		TravellerBoots = "Traveller's Boots",
		HuntingDagger = "Hunting Dagger",
		MiningPickaxe = "Mining Pickaxe",

		SlimeCore = "Slime Core",
		SlimeGel = "Slime Gel",
		SpikyFur = "Spiky Fur",
		SpikyQuills = "Spiky Quills",
		BlackFur = "Black Fur",
		BlackQuills = "Black Quills",

		ValkyrieArmor = "Valkyrie Armor",
	},

	IsSkill = {
		FireballScroll = true
	},

	ItemDesc = {
		HealthyApple = "A very healthy apple from healthy tree",
		GoldenApple = "A gift for those people who are lucky",
		FireballScroll = "A magical scroll created by great wizards",

		TravellerBoots = "A pair of comfortable boots",
		HuntingDagger = "A sharp dagger for hunting foxes",
		MiningPickaxe = "A pickaxe for mining ores",

		SlimeCore = "The core of slimes, a good material for alchemy",
		SlimeGel = "The gel of slimes, sticky",
		SpikyFur = "The alternative version of Kitsune Fur",
		SpikyQuills = "The quills, a nice material for crafting",
		BlackFur = "At least it's better than Spiky Fur, but manifesting negative energy",
		BlackQuills = "Basically it's Spiky Quills, but has energy in it",

		ValkyrieArmor = "Forged from adamantite and orichalcum along with enchantments of light",
	},

	--- 00ff00 green, ff3333 red, 11ebee blue, b266ff purple
	ItemStat = {
		HealthyApple = "Heals <font color='#00FF00'>5%</font> of your max Health.",
		GoldenApple = "Recover <font color='#00FF00'>15% of</font> max Health and gives <font color='#FF3333'>1.5x DMG</font> buff for <font color='#11ebee'>5s</font>.",
		FireballScroll = "Shoot a fireball towards the monster, deals <font color='#B266FF'>0.5x of magic damage</font> and <font color='#11ebee'>burn effect</font> <font color='#FF3333'>if hits</font>, costs <font color='#11ebee'>100 Mana</font>",

		TravellerBoots = "<font color='#11ebee'>+6 Speed</font>, it's comfortable so you can walk faster",
		HuntingDagger = "<font color='#FF3333'>+5 Damage</font>, simple",
		MiningPickaxe = "<font color='#FF3333'>+5 Damage</font>, and allow you to get materials from minerals",

		SlimeCore = "Can be used for crafting, and alchemy",
		SlimeGel = "Can be used for crafting",
		SpikyFur = "Can be used for crafting",
		SpikyQuills = "Can be used for crafting, and reforging",
		BlackFur = "Can be used for crafting",
		BlackQuills = "Can be used for crafting, and reforging",

		ValkyrieArmor = "Used by the valkyries from Valhalla",
	},

	ItemTier = {
		HealthyApple = "Common",
		GoldenApple = "Rare",
		FireballScroll = "Rare",

		TravellerBoots = "Common",
		HuntingDagger = "Common",
		MiningPickaxe = "Common",

		SlimeCore = "Common",
		SlimeGel = "Rare",
		SpikyFur = "Common",
		SpikyQuills = "Rare",
		BlackFur = "Epic",
		BlackQuills = "Ultra",

		ValkyrieArmor = "Ultra",
	},

	ItemType = {
		HealthyApple = "Active",
		GoldenApple = "Active",
		FireballScroll = "Active",

		TravellerBoots = "Passive",
		HuntingDagger = "Passive",
		MiningPickaxe = "Passive",

		SlimeCore = "Material",
		SlimeGel = "Material",
		SpikyFur = "Material",
		SpikyQuills = "Material",
		BlackFur = "Material",
		BlackQuills = "Material",

		ValkyrieArmor = "Cosmetic",
	},

	ItemImages = {
		Null = "rbxassetid://1637592633",
		Unknown = "rbxassetid://2985521957",

		HealthyApple = "rbxassetid://1637563032",
		GoldenApple = "rbxassetid://2970814988",
		FireballScroll = "rbxassetid://12192842137",

		TravellerBoots = "rbxassetid://2965728606",
		HuntingDagger = "rbxassetid://1723200131",
		MiningPickaxe = "rbxassetid://12118509077",

		SlimeCore = "rbxassetid://12118510527",
		SlimeGel = "rbxassetid://2980409698",
		SpikyFur = "rbxassetid://12118511428",
		SpikyQuills = "rbxassetid://2980409932",
		BlackFur = "rbxassetid://12285144842",
		BlackQuills = "rbxassetid://2985521957",

		ValkyrieArmor = "rbxassetid://14429563981",
	},
}

return assets
