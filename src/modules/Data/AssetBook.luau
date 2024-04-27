--!nocheck
--!optimize 2
--!native

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
	six = newTweenInfo(6),
    fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
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
	Quest = fromRGB(46, 213, 115),
}
assets.QuestColor = {
    Main = fromRGB(46, 213, 115),
    Side = fromRGB(255, 165, 2),
    Town = fromRGB(255, 107, 129)
}
assets.ChatIcons = {
    Chat = "rbxassetid://13124035950",
    Exit = "rbxassetid://16458254833",
    Buy = "rbxassetid://16458319981",
    Craft = "rbxassetid://16458320089",
    Quest = "rbxassetid://16468992982"
}
assets.PromptIcons = {
    Chat = "rbxassetid://13124035950",
    Quest = "rbxassetid://16468992982",
    Travel = "rbxassetid://16458254833"
}
assets.ActionPanelIcons = {
    Attack = "rbxassetid://2034122114",
    Items = "rbxassetid://2228031606",
    Skills = "rbxassetid://2034172262",
    Defend = "rbxassetid://4601012009"
}
assets.ClassInfo = {
	Warrior = {
		Image = "rbxassetid://2965862892",
		Color = fromRGB(255, 100, 100),
        Type = "DMG"
	},
	Archer = {
		Image = "rbxassetid://2965863905",
		Color = fromRGB(100, 255, 100),
        Type = "DMG"
	},
	Wizard = {
		Image = "rbxassetid://2965863231",
		Color = fromRGB(100, 100, 254),
        Type = "Magic"
	},
	Knight = {
		Image = "rbxassetid://2965863677",
		Color = fromRGB(255, 255, 50),
        Type = "DMG"
	},
	Rogue = {
		Image = "rbxassetid://12284961892",
		Color = fromRGB(255, 170, 255),
        Type = "DMG"
	},
	Repeater = {
		Image = "rbxassetid://12190533959",
		Color = fromRGB(65, 179, 255),
        Type = "DMG"
	},
	Striker = {
		Image = "rbxassetid://12190535870",
		Color = fromRGB(253, 148, 44),
        Type = "DMG"
	},
	Alchemist = {
		Image = "rbxassetid://12236618949",
		Color = fromRGB(0, 255, 22),
        Type = "Magic"
	},
	Illusionist = {
		Image = "rbxassetid://15875390788",
		Color = fromRGB(0, 255, 252),
        Type = "Magic"
	}
}
assets.MonsterAvatars = {
	["Spike Fox"] = "rbxassetid://13886503379",
	["Spike Wolf"] = "rbxassetid://16483664838",
    ["Thorn Wolf"] = "rbxassetid://15688333529",
    ["Needle Wolf"] = "rbxassetid://15688333529",
    ["Lava Wolf"] = "rbxassetid://16483654080",

	["Green Slime"] = "rbxassetid://15951815518",
    ["Blue Slime"] = "rbxassetid://16483649460",
    ["Lapis Slime"] = "rbxassetid://16483649287",
    ["Purple Slime"] = "rbxassetid://16483649160",
    ["Rock Slime"] = "rbxassetid://16483665012",
}
assets.BuffImages = {
    AttackBuff = "rbxassetid://2965862892",
    MagicBuff = "rbxassetid://2965863231",
    Burn = "rbxassetid://12218488404",
    Poison = "rbxassetid://12371171272"
}
assets.BuffColors = {
    AttackBuff = fromRGB(255, 255, 255),
    MagicBuff = fromRGB(255, 255, 255),
    Burn = fromRGB(255, 0, 0),
    Poison = fromRGB(170, 85, 255)
}

assets.LocationInfo = {
	Name = {
        InitusVillage = "Initus Village",
        MonolithGrove = "Monolith Grove",
		InitusBay = "Initus Bay",
		PrimisField = "Primis Field",
		SonusCave = "Sonus Cave",
        MisniPort = "Misni Port",
        Highland = "High Lands",
        Tundra = "Tundra",

        TestPlace = "Secret Cave"
	},
	Desc = {
		InitusVillage = "The start of every adventure...",
        MonolithGrove = "Other than the sound of foxes, you can hardly hear any other noises.",
        InitusBay = "You feel like you've come here multiple times...",
		PrimisField = "The old memories with Slimes...",
		SonusCave = "Bats make you crazy.",
        MisniPort = "Another port, larger than Initus Bay",
        Highland = "I don't know why it's called High Lands...",
        Tundra = "The temperature start to drop...",

        TestPlace = "A cave that everyone can't find out, but luckily now you can find it."
	},
    Music = {
        InitusVillage = "rbxassetid://11130054413",
        MonolithGrove = "rbxassetid://11130054413",
        InitusBay = "rbxassetid://10717248822",
		PrimisField = "rbxassetid://10717248822",
		SonusCave = "rbxassetid://12076218714",
        MisniPort = "rbxassetid://16471110687",
        Highland = "rbxassetid://15842496353",
        Tundra = "rbxassetid://12294493784",

        TestPlace = "rbxassetid://11130054413",
    },
    MusicVolumes = {
        ["rbxassetid://11130054413"] = 0.5, --- initus village
        ["rbxassetid://10717248822"] = 0.5, --- initus bay
        ["rbxassetid://15842496353"] = 1, --- highland
        ["rbxassetid://16471110687"] = 0.3, --- misni port
        ["rbxassetid://12076218714"] = 0.5, --- sonus cave
        ["rbxassetid://12294493784"] = 0.5 --- tundra
    }
}

assets.Items = {
	ItemCost = {},

	ItemName = {
        HealthyApple = "Healthy Apple",
        GoldenApple = "Golden Apple",
        HealthPotion = "Health Potion",
        PowerPotion = "Power Potion",
        HastePotion = "Haste Potion",
        MagicPotion = "Magic Potion",
        FireballScroll = "Ignition Scroll",
        BloxyCola = "Bloxy Cola",
        CookedSteak = "Cooked Steak",
        ArcaneMark = "Arcane Mark",
        DarkChain = "Eternal Chain",
        ExtraJump = "Extra Jump",
        FoxFlameScroll = "Kitsune Flame Scroll",
        GhostlyLantern = "Ghostly Lantern",
        HolySmite = "Holy Smite",
        Lux = "Lux",
        WarriorsPride = "Warrior's Pride",

        TravellerBoots = "Traveller's Boots",
        BurningTorch = "Burning Torch",
        CampfireWood = "Campfire Wood",
        HuntingDagger = "Hunting Dagger",
        MiningPickaxe = "Mining Pickaxe",
        CopperSword = "Copper Sword",
        AncientHammer = "Ancient Hammer",
        ManaCrystal = "Raw Mana Crystal",
        AdventurersKit = "Adventurer's Kit",
        RabbitFoot = "Rabbit's Foot",
        ArcaneSpellbook = "Arcane Spellbook",
        MagicianHat = "Magician's Hat",
        EnchantedBlade = "Enchanted Blade",
        StalkerCape = "Stalker Cape",
        RegenerationGem = "Gem of Regeneration",
        BlackWolfNecklace = "Black Wolf Necklace",
        FlameSword = "Flame Sword",
        KitsuneGloves = "Kitsune Gloves",
        AquaLapis = "Auqa Gem",
        MagicWand = "Magic Wand",
        EverfrostSeeds = "Everfrost Seeds",
        HotPotato = "Hot Potato",
        NorthernerAxe = "Northerner's Axe",
        TundraGear = "Tundra Cloak",
        FoxSpirit = "Kitsune's Spirit",
        NorthernHalberd = "Northern Halberd",
        AbsorptionCrystal = "Absorption Crystal",
        FireStaff = "Fire Staff",
        MountainKingCrown = "Frozen Rose Crown",
        MilkPillow = "Milk's Pillow",

        SlimeCore = "Slime Core",
        SlimeGel = "Slime Gel",
        SpikyFur = "Spiky Fur",
        SpikyQuills = "Spiky Quills",
        StalkerLog = "Stalker Log",
        StalkerLeaf = "Stalker Leaf",
        StalkerBranch = "Stalker Branch",
        KitsuneFur = "Kitsune Fur",
        KitsuneFlame = "Kitsune Flame",
        Iron = "Iron Ore",
        BlackFur = "Black Fur",

        ValkyrieArmor = "Valkyrie Armor",

        HeheLetter = "A Letter From Hehe"
    },

	IsSkill = {
		FireballScroll = true,
		ArcaneMark = true,
		DarkChain = true,
		ExtraJump = true,
		FoxFlameScroll = true,
		GhostlyLantern = true,
		HolySmite = true,
		Lux = true,
		WarriorsPride = true
	},

    ItemDesc = {
        HealthyApple = "A very healthy apple from healthy tree",
        GoldenApple = "A gift for those people who are lucky",
        HealthPotion = "Created by great alchemists, not so tasty",
        PowerPotion = "Created by great alchemists who controls Mind",
        HastePotion = "Created by great alchemists who controls Time",
        MagicPotion = "Created by great alchemists who controls Heart",
        FireballScroll = "A magical scroll created by great wizards",
        BloxyCola = "Refreshing sweet soda that would give you a sugar rush",
        CookedSteak = "Tasty, a piece of well cooked steak",
        ArcaneMark = "wait, where is the magic circle?",
        DarkChain = "Summons a chain using the power of darkness",
        ExtraJump = "A skill that gives you extra jumps, simple",
        FoxFlameScroll = "Kitsunes always carry these scrolls just to find a new master",
        GhostlyLantern = "Unleash the power of the ghosts to haunt you enemies",
        HolySmite = "A spell that calls the heaven's smite",
        Lux = "A spell that casts a ball of light",
        WarriorsPride = "A skill that as been used by warriors",

        TravellerBoots = "A pair of comfortable boots",
        BurningTorch = "Magical torch that burns even in rain",
        CampfireWood = "Wonderful, isn't it?",
        HuntingDagger = "A sharp dagger for hunting foxes",
        MiningPickaxe = "A pickaxe for mining ores",
        CopperSword = "It has a long history...",
        AncientHammer = "You feel the many battles and fights it's been through",
        ManaCrystal = "A Raw mana crystal, it contains some mana inside it",
        AdventurersKit = "A trusty kit useful for exploring and...more useful killing monsters.",
        RabbitFoot = "Is this just a cosmetic?",
        ArcaneSpellbook = "A magical spellbook used by The Life Faction members",
        MagicianHat = "It is said that The Matter Faction members usually have this hat",
        EnchantedBlade = "A sword blessed by magic",
        StalkerCape = "A cape made out of stalker leaves.",
        RegenerationGem = "A gem that warmth your heart",
        BlackWolfNecklace = "It's your glory by beating the wolf king",
        FlameSword = "Sharp, and Hot, perfect for the battle",
        KitsuneGloves = "It warmth your hands, kitsune's fur is good ngl",
        AquaLapis = "An incredibly rare stone with magical properties based off water.",
        MagicWand = "A wand usually used by The Magic Council members",
        EverfrostSeeds = "An identification or a sign of being worthy to enter their stronghold",
        HotPotato = "Not actually a potato, it is just a piece of charcoal that has absorbed a lot of heat",
        NorthernerAxe = "Used by soldiers from the north",
        TundraGear = "Used by hikers and adventurers",
        FoxSpirit = "Back in the grasslands, there once was a sighting of a kitsune that romed around here...",
        NorthernHalberd = "A great halberd forged within the Northern Stronghold.",
        AbsorptionCrystal = "A magical crystal taken deep below from the caverns",
        FireStaff = "This little girl cannot explain this staff",
        MountainKingCrown = "A crown that belongs to an ancient king, well he is dead now soooo grave robbing?",
        MilkPillow = "Milk's favorite pillow, you can get DEV POWER from this, also, how did you get this?",

        SlimeCore = "The core of slimes, a good material for alchemy",
        SlimeGel = "The gel of slimes, sticky",
        SpikyFur = "The alternative version of Kitsune Fur",
        SpikyQuills = "The quills, a nice material for crafting",
        StalkerLog = "The log of trees, but has stalker energy in it",
        StalkerLeaf = "The leaves of trees, but stalker makes them more lush",
        StalkerBranch = "The branch of trees, a good material for reforge weapons",
        KitsuneFur = "A soft fur that has magical coating within it, you can feel the warmth",
        KitsuneFlame = "The inner spell of Kitsune, it's surprising that the flame doesn't hurt you",
        Iron = "The classic metal everyone in the world has used",
        BlackFur = "At least it's better than Spiky Fur, but manifesting negative energy",

        ValkyrieArmor = "Forged from adamantite and orichalcum along with enchantments of light",

        HeheLetter = "Without any scent on it, after all, it is just the most ordinary letter."
    },

    --- 00ff00 green, ff3333 red, 11ebee blue, b266ff purple
    ItemStat = {
        HealthyApple = "Heals <font color='#00FF00'>10%</font> of your max HP, and you need <font color='#11ebee'>1s</font> to eat it",
        GoldenApple = "Recover <font color='#00FF00'>half of</font> max HP and gives <font color='#FF3333'>1.5x DMG</font> buff for <font color='#11ebee'>5s</font>, along with <font color='#11ebee'>10s</font> cooldown",
        HealthPotion = "Heals for <font color='#00FF00'>15%</font> max HP, but it has <font color='#11ebee'>2s</font> cooldown",
        PowerPotion = "Gives <font color='#FF3333'>1.5x DMG</font> buff for <font color='#11ebee'>5s</font>, can't drink again until <font color='#11ebee'>10s</font> later",
        HastePotion = "Gain <font color='#11ebee'>15 Speed</font> for <font color='#11ebee'>10s</font>, but the world needs to rest for <font color='#11ebee'>15s</font>",
        MagicPotion = "Gives <font color='#B266FF'>1.5x Magic</font> buff for <font color='#11ebee'>5s</font>, it will break your Heart if you don't rest for <font color='#11ebee'>10s</font>",
        FireballScroll = "Shoot a fireball towards the monster, deals <font color='#B266FF'>0.5x of magic damage</font> <font color='#FF3333'>if hits</font>, has <font color='#11ebee'>10s</font> cooldown, costs <font color='#11ebee'>100 MP</font>",
        BloxyCola = "Gain <font color='#11ebee'>10</font> speed for <font color='#11ebee'>5s</font>, and heals <font color='#00FF00'>30%</font> HP, along with <font color='#11ebee'>10s</font> cooldown",
        CookedSteak = "Gives <font color='#FF3333'>1.5x DMG</font> buff for <font color='#11ebee'>5s</font> and heals <font color='#00FF00'>25%</font> HP, along with <font color='#11ebee'>10s</font> cooldown",
        ArcaneMark = "Mark an area under the monster which deals <font color='#B266FF'>magic damage</font> over time, costs <font color='#11ebee'>600 MP</font>, along with <font color='#11ebee'>10s</font> cooldown",
        DarkChain = "Pulls you into the air towards the monster and then damaging for both <font color='#FF3333'>physical</font> and <font color='#B266FF'>magical</font> damage, costs <font color='#11ebee'>300 MP</font>, along with <font color='#11ebee'>7s</font> cooldown",
        ExtraJump = "Boosts you up, with an extra jump, with 7s cooldown.",
        FoxFlameScroll = "Shoot a fireball towards the monster, deals <font color='#B266FF'>magical damage</font> <font color='#FF3333'>if hits</font>, has <font color='#11ebee'>7s</font> cooldown, costs <font color='#11ebee'>50 MP</font>",
        GhostlyLantern = "Damage the monster proportional to your <font color='#B266FF'>magic damage</font>, costs <font color='#11ebee'>600 MP</font>, along with <font color='#11ebee'>10s</font> cooldown",
        HolySmite = "A beam of light strikes down the monster causing powerful <font color='#B266FF'>magical damage</font>, costs <font color='#11ebee'>600 MP</font>, along with <font color='#11ebee'>10s</font> cooldown",
        Lux = "Shoot a ball towards the monster, deals <font color='#B266FF'>magic damage</font> <font color='#FF3333'>if hits</font>, has <font color='#11ebee'>7s</font> cooldown, costs <font color='#11ebee'>50 MP</font>",
        WarriorsPride = "Slash out a blade of pure raw physical energy that deals <font color='#FF3333'>4x damage</font> based on your maximum damage <font color='#FF3333'>if hits</font>, has <font color='#11ebee'>10s</font> cooldown",

        TravellerBoots = "<font color='#11ebee'>+10 Speed</font>, it's comfortable so you can walk faster",
        BurningTorch = "Emitting light wherever you are, and others can also see the light",
        CampfireWood = "<font color='#00FF00'>+20 Max HP</font>, and let you heals <font color='#00FF00'>30% more</font> at campfires",
        HuntingDagger = "<font color='#FF3333'>+5 Min Damage</font>, simple",
        MiningPickaxe = "<font color='#FF3333'>+5 Max Damage</font>, and allow you to get materials from minerals",
        CopperSword = "<font color='#FF3333'>+15 Max Damage</font>, it can be more powerful after reforged",
        AncientHammer = "<font color='#FF3333'>+40 Max Damage</font>, and <font color='#00FF00'>+120 Shield</font>",
        ManaCrystal = "<font color='#B266FF'>+20 Magic</font>, and restore <font color='#11ebee'>5% of your Max MP</font> every second",
        AdventurersKit = "There'll be 3 orbs already spawned when you start the battle",
        RabbitFoot = "<font color='#11ebee'>+40 Jump</font>, and <font color='#11ebee'>+5 Speed</font>",
        ArcaneSpellbook = "<font color='#B266FF'>+125 Magic</font>, and allow you to join The Life Faction",
        MagicianHat = "<font color='#B266FF'>+125 Magic</font>, and allow you to join The Matter Faction",
        EnchantedBlade = "<font color='#FF3333'>+70 Max Damage</font>, <font color='#11ebee'>+30 Min Damage</font>, and <font color='#B266FF'>+60 Magic</font>",
        StalkerCape = "+13% chance to dodge monster's attacks, except Abyss",
        RegenerationGem = "<font color='#11ebee'>Heals 30% HP</font> every 30 seconds",
        BlackWolfNecklace = "<font color='#FF3333'>+200 Max Damage</font>, and <font color='#11ebee'>+10 Speed</font>",
        FlameSword = "<font color='#FF3333'>+100 Max Damage</font>, and <font color='#11ebee'>30% chance</font> to Burn enemy when you attack",
        KitsuneGloves = "<font color='#FF3333'>+50 Max Damage</font>, <font color='#B266FF'>+50 Magic</font>, and <font color='#11ebee'>+5%</font> critical chance",
        AquaLapis = "<font color='#11ebee'>+600 Max MP</font>, and restore <font color='#11ebee'>30% more MP</font> when you attack",
        MagicWand = "<font color='#B266FF'>+125 Magic</font>, and allow you to join The Magic Council",
        EverfrostSeeds = "Allows you to enter Northern Stronghold",
        HotPotato = "<font color='#11ebee'>+10 Speed</font>, and <font color='#11ebee'>+10% chance</font> to Burn enemy when attack",
        NorthernerAxe = "<font color='#FF3333'>+70 Max Damage</font>, and allow you to cut trees",
        TundraGear = "Allows the person to withstand the immense cold of Tundra",
        FoxSpirit = "<font color='#B266FF'>+50 Magic</font>, <font color='#11ebee'>+30 Speed</font> with the aid of the Fox's Spirit",
        NorthernHalberd = "<font color='#FF3333'>+100 Min Damage</font>, and <font color='#FF3333'>+125 Max Damage</font>",
        AbsorptionCrystal = "Restore <font color='#11ebee'>20% Shield</font> whenever you land an attack",
        FireStaff = "Summons Red Staves that will inflict Burn on hit",
        MountainKingCrown = "<font color='#FF3333'>+150 Max Damage</font>, and be the King of Assassin Faction",
        MilkPillow = "No actual effect, well JK, <font color='#FF3333'>+9999 Max Damage</font>",

        SlimeCore = "Can be used for crafting, and alchemy",
        SlimeGel = "Can be used for crafting",
        SpikyFur = "Can be used for crafting",
        SpikyQuills = "Can be used for crafting, and reforging",
        StalkerLog = "Can be used for crafting",
        StalkerLeaf = "Can be used for alchemy",
        StalkerBranch = "Can be used for reforging",
        KitsuneFur = "Can be used for crafting",
        KitsuneFlame = "Can be used for reforging, and alchemy",
        Iron = "Can be used for reforging, and crafting",
        BlackFur = "Can be used for crafting",

        ValkyrieArmor = "Used by the valkyries from Valhalla",

        HeheLetter = "A letter from Hehe in Initus Bay, maybe you will get good rewards in the future."
    },

    ItemTier = {
        HealthyApple = "Common",
        HealthPotion = "Common",
        PowerPotion = "Common",
        MagicPotion = "Common",
        HastePotion = "Common",
        SlimeCore = "Common",
        SpikyFur = "Common",
        StalkerLeaf = "Common",
        KitsuneFur = "Common",
        Iron = "Common",
        StalkerBranch = "Common",
        TravellerBoots = "Common",
        BurningTorch = "Common",
        CampfireWood = "Common",
        HuntingDagger = "Common",
        MiningPickaxe = "Common",
        RabbitFoot = "Common",
        HeheLetter = "Common",

        GoldenApple = "Rare",
        FireballScroll = "Rare",
        SlimeGel = "Rare",
        SpikyQuills = "Rare",
        StalkerLog = "Rare",
        KitsuneFlame = "Rare",
        BloxyCola = "Rare",
        CookedSteak = "Rare",
        ArcaneMark = "Rare",
        CopperSword = "Rare",
        AncientHammer = "Rare",
        ManaCrystal = "Rare",
        AdventurersKit = "Rare",
        ArcaneSpellbook = "Rare",
        MagicianHat = "Rare",
        EnchantedBlade = "Rare",
        StalkerCape = "Rare",
        RegenerationGem = "Rare",
        KitsuneGloves = "Rare",
        MagicWand = "Rare",
        HotPotato = "Rare",
        NorthernerAxe = "Rare",
        TundraGear = "Rare",
        DarkChain = "Rare",
        ExtraJump = "Rare",
        GhostlyLantern = "Rare",
        HolySmite = "Rare",
        Lux = "Rare",
        NorthernHalberd = "Rare",
        AbsorptionCrystal = "Rare",

        FlameSword = "Epic",
        AquaLapis = "Epic",
        FoxFlameScroll = "Epic",
        BlackFur = "Epic",
        FoxSpirit = "Epic",
        ValkyrieArmor = "Epic",
        FireStaff = "Epic",
        WarriorsPride = "Epic",

        EverfrostSeeds = "Mythic",
        BlackWolfNecklace = "Mythic",
        MountainKingCrown = "Mythic",
        MilkPillow = "Mythic"
    },

    ItemType = {
        HealthyApple = "Active",
        HealthPotion = "Active",
        PowerPotion = "Active",
        MagicPotion = "Active",
        HastePotion = "Active",
        GoldenApple = "Active",
        FireballScroll = "Active",
        BloxyCola = "Active",
        CookedSteak = "Active",
        ArcaneMark = "Active",
        DarkChain = "Active",
        ExtraJump = "Active",
        FoxFlameScroll = "Active",
        GhostlyLantern = "Active",
        HolySmite = "Active",
        Lux = "Active",
        WarriorsPride = "Active",

        TravellerBoots = "Passive",
        BurningTorch = "Passive",
        CampfireWood = "Passive",
        HuntingDagger = "Passive",
        MiningPickaxe = "Passive",
        CopperSword = "Passive",
        AncientHammer = "Passive",
        ManaCrystal = "Passive",
        AdventurersKit = "Passive",
        RabbitFoot = "Passive",
        ArcaneSpellbook = "Passive",
        MagicianHat = "Passive",
        EnchantedBlade = "Passive",
        StalkerCape = "Passive",
        RegenerationGem = "Passive",
        BlackWolfNecklace = "Passive",
        FlameSword = "Passive",
        KitsuneGloves = "Passive",
        AquaLapis = "Passive",
        MagicWand = "Passive",
        EverfrostSeeds = "Passive",
        HotPotato = "Passive",
        NorthernerAxe = "Passive",
        TundraGear = "Passive",
        FoxSpirit = "Passive",
        NorthernHalberd = "Passive",
        AbsorptionCrystal = "Passive",
        FireStaff = "Passive",
        MountainKingCrown = "Passive",
        MilkPillow = "Passive",

        SlimeCore = "Material",
        SlimeGel = "Material",
        SpikyFur = "Material",
        SpikyQuills = "Material",
        StalkerLog = "Material",
        StalkerLeaf = "Material",
        StalkerBranch = "Material",
        KitsuneFur = "Material",
        KitsuneFlame = "Material",
        Iron = "Material",
        BlackFur = "Material",

        ValkyrieArmor = "Cosmetic",

        HeheLetter = "Quest"
    },

    ItemImages = {
        Null = "rbxassetid://1637592633",
        Unknown = "rbxassetid://2985521957",

        Gold = "rbxassetid://16654275243",
        RP = "rbxassetid://16002068286",

        HealthyApple = "rbxassetid://1637563032",
        GoldenApple = "rbxassetid://2970814988",
        HealthPotion = "rbxassetid://2970816690",
        PowerPotion = "rbxassetid://2970818097",
        HastePotion = "rbxassetid://2970816149",
        MagicPotion = "rbxassetid://2970818438",
        FireballScroll = "rbxassetid://12027128477",
        BloxyCola = "rbxassetid://4865339572",
        CookedSteak = "rbxassetid://4795912293",
        ArcaneMark = "rbxassetid://14429505922",
        DarkChain = "rbxassetid://16517558370",
        ExtraJump = "rbxassetid://4821548100",
        FoxFlameScroll = "rbxassetid://16517556428",
        GhostlyLantern = "rbxassetid://16517557897",
        HolySmite = "rbxassetid://14429523818",
        Lux = "rbxassetid://17286829881",
        WarriorsPride = "rbxassetid://17286830224",

        TravellerBoots = "rbxassetid://17286829777",
        BurningTorch = "rbxassetid://17286830043",
        CampfireWood = "rbxassetid://2970559088",
        HuntingDagger = "rbxassetid://16483882733",
        MiningPickaxe = "rbxassetid://12118509077",
        CopperSword = "rbxassetid://12192841092",
        AncientHammer = "rbxassetid://12119868315",
        ManaCrystal = "rbxassetid://12119869276",
        AdventurersKit = "rbxassetid://12370527641",
        RabbitFoot = "rbxassetid://16517558186",
        ArcaneSpellbook = "rbxassetid://17286830798",
        EnchantedBlade = "rbxassetid://17286830606",
        MagicianHat = "rbxassetid://14429547149",
        StalkerCape = "rbxassetid://12284033809",
        RegenerationGem = "rbxassetid://12284830343",
        BlackWolfNecklace = "rbxassetid://12285163433",
        FlameSword = "rbxassetid://12286573185",
        KitsuneGloves = "rbxassetid://12285229661",
        AquaLapis = "rbxassetid://16517556825",
        MagicWand = "rbxassetid://14429543328",
        EverfrostSeeds = "rbxassetid://14429517439",
        HotPotato = "rbxassetid://16517558564",
        NorthernerAxe = "rbxassetid://14429550726",
        TundraGear = "rbxassetid://16517557366",
        FoxSpirit = "rbxassetid://16517557109",
        NorthernHalberd = "rbxassetid://4827596848",
        AbsorptionCrystal = "rbxassetid://4820513616",
        FireStaff = "rbxassetid://17286829652",
        MountainKingCrown = "rbxassetid://17286830433",
        MilkPillow = "rbxassetid://15753183350",

        SlimeCore = "rbxassetid://12118510527",
        SlimeGel = "rbxassetid://2980409698",
        SpikyFur = "rbxassetid://12118511428",
        SpikyQuills = "rbxassetid://2980409932",
        StalkerLog = "rbxassetid://12159550747",
        StalkerLeaf = "rbxassetid://12159549738",
        StalkerBranch = "rbxassetid://12333618023",
        KitsuneFur = "rbxassetid://12191831926",
        KitsuneFlame = "rbxassetid://14429538456",
        Iron = "rbxassetid://16517616804",
        BlackFur = "rbxassetid://12285144842",

        ValkyrieArmor = "rbxassetid://14429563981",

        HeheLetter = "rbxassetid://16654291188"
    }
}

return assets
