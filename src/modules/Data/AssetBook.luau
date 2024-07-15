--!nocheck

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

local AssetBook = {}

AssetBook.TweenInfos = {
	fourHalf = newTweenInfo(0.05),
    fourOneHalf = newTweenInfo(0.1),
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
    three = newTweenInfo(3),
    four = newTweenInfo(4),
	six = newTweenInfo(6),
    fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}

AssetBook.TierColor = {
	fromRGB(0, 255, 0),
	fromRGB(49, 226, 236),
	fromRGB(214, 96, 253),
	fromRGB(250, 250, 65),
	fromRGB(255, 22, 57),
}

AssetBook.QuestColor = {
    Main = fromRGB(46, 213, 115),
    Side = fromRGB(255, 165, 2),
    Town = fromRGB(255, 107, 129)
}

AssetBook.RankRoleInfo = {
    [2] = {
        Role = "CS Tester",
        ChatRole = "Tester",
        Color = "#70a1ff"
    },
    [3] = {
        Role = "CS Grand Tester",
        ChatRole = "Tester+",
        Color = "#1e90ff"
    },
    [4] = {
        Role = "CS Trello Contributor",
        ChatRole = "Trello",
        Color = "#5352ed"
    },
    [125] = {
        Role = "CS Contributor",
        ChatRole = "Contributor",
        Color = "#ff6b81"
    },
    [126] = {
        Role = "CS Moderator",
        ChatRole = "Mod",
        Color = "#ff4757"
    },
    [255] = {
        Role = "CS Founder",
        ChatRole = "Founder",
        Color = "#ffa502"
    },
}
AssetBook.CustomRoleInfo = {
    ["68027875"] = {
        Role = "CW Founder",
        ChatRole = "CW Founder",
        Color = "#ffa502"
    },
    ["2040399306"] = {
        Role = "CSV Founder",
        ChatRole = "CSV Founder",
        Color = "#ffa502"
    },
    ["1097119343"] = {
        Role = "CV Founder",
        ChatRole = "CV Founder",
        Color = "#ffa502"
    },
    ["3563941913"] = {
        Role = "CO Founder",
        ChatRole = "CO Founder",
        Color = "#ffa502"
    },
    ["91364976"] = {
        Role = "CR Founder",
        ChatRole = "CR Founder",
        Color = "#ffa502"
    },

    ["517042349"] = {
        Role = "Abyss The Executor",
        ChatRole = "Abyss",
        Color = "#3742fa"
    },
    ["850971587"] = {
        Role = "Alchemist User",
        ChatRole = "Alchemist",
        Color = "#7bed9f"
    },
    ["596899926"] = {
        Role = "Mayor of Carrotopia",
        ChatRole = "Carrot",
        Color = "#ff7f50"
    },
    ["748297118"] = {
        Role = "Known Illegal Merchant",
        ChatRole = "Merchant",
        Color = "#fd79a8"
    },
    ["332773444"] = {
        Role = "Sigma Male",
        ChatRole = "Sigma",
        Color = "#74b9ff"
    },
    ["1196067403"] = {
        Role = "Tree Monster Fanatic",
        ChatRole = "Tree",
        Color = "#2ed573"
    },
    ["1210467492"] = {
        Role = "Thingamybob",
        ChatRole = "Snow",
        Color = "#fff"
    },
    ["1680347725"] = {
        Role = "Strategist",
        ChatRole = "Strategist",
        Color = "#fff"
    },
    ["1457659888"] = {
        Role = "Striker",
        ChatRole = "Striker",
        Color = "#f79f1f"
    },
    ["1312728712"] = {
        Role = "Raid Shadow Legend",
        ChatRole = "Raid Shadow",
        Color = "#fd79a8"
    },
    ["1094363213"] = {
        Role = "Ebalo",
        ChatRole = "Ebalo",
        Color = "#e056fd"
    },
    ["232313396"] = {
        Role = "Mia",
        ChatRole = "Mia",
        Color = "#fd79a8"
    }
}

AssetBook.PromptIcons = {
    Chat = "rbxassetid://13124035950",
    Exit = "rbxassetid://16458254833",
    Buy = "rbxassetid://16458319981",
    Craft = "rbxassetid://16458320089",
    Quest = "rbxassetid://16468992982",
    Travel = "rbxassetid://16458254833"
}

AssetBook.ClassInfo = {
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
		Color = fromRGB(43, 188, 93),
        Type = "Magic"
	},
	Illusionist = {
		Image = "rbxassetid://15875390788",
		Color = fromRGB(0, 255, 252),
        Type = "Magic"
	},
    Juggernaut = {
        Image = "rbxassetid://16654290906",
        Color = fromRGB(253, 148, 44),
        Type = "DMG"
    },
    Reaper = {
        Image = "rbxassetid://17667241921",
        Color = fromRGB(163, 39, 39),
        Type = "DMG"
    },
    WindDancer = {
        Image = "rbxassetid://18423401512",
        Color = Color3.fromHex('#70a1ff'),
        Type = "DMG"
    }
}

AssetBook.WorldInfo = {
	Mainworld = 12343565896, PrivateTest = 12003361010, NiximCavern = 12294239008,
	CE = 17302653565, TimeDomain = 11904003271, Everfrost = 12373196969,
	Stronghold = 12373229403, Arkus = 13970315225, LoneTown = 16555333700,
	SummerIsland = 17444533020
}

AssetBook.MonsterInfo = {
    SpikeFox = {
        Name = "Spike Fox",
        Icon = "rbxassetid://13886503379",
        IdleAnim = "SpikeWolfIdle",

        Drops = {
            SpikyFur = 80,
            SpikyQuills = 20
        }
    },
    SpikeWolf = {
        Name = "Spike Wolf",
        Icon = "rbxassetid://16483664838",
        IdleAnim = "SpikeWolfIdle",

        Drops = {
            SpikyFur = 70,
            SpikyQuills = 30
        }
    },
    ThornWolf = {
        Name = "Thorn Wolf",
        Icon = "rbxassetid://16483664838",
        IdleAnim = "SpikeWolfIdle",

        Drops = {
            SpikyFur = 60,
            SpikyQuills = 40
        }
    },
    HardmodeWolf = {
        Name = "Hardmode Wolf",
        Icon = "rbxassetid://15688333545",
        IdleAnim = "SpikeWolfIdle",

        Drops = {
            BlackFur = 90,
            BlackwolfNecklace = 10
        }
    },

    Kitsune = {
        Name = "Kitsune",
        Icon = "rbxassetid://17543155124",
        IdleAnim = "SpikeWolfIdle",

        Drops = {
            KitsuneFur = 60,
            KitsuneFlame = 40
        }
    },
    Stalker = {
        Name = "Stalker",
        Icon = "rbxassetid://17543156640",
        IdleAnim = "SlimeIdle",

        Drops = {
            StalkerLeaf = 60,
            StalkerLog = 40,
        }
    },

    GreenSlime = {
        Name = "Green Slime",
        Icon = "rbxassetid://15951815518",
        IdleAnim = "SlimeIdle",

        Drops = {
            SlimeGel = 80,
            SlimeCore = 20
        }
    },
    BlueSlime = {
        Name = "Blue Slime",
        Icon = "rbxassetid://16483649460",
        IdleAnim = "SlimeIdle",

        Drops = {
            SlimeGel = 70,
            SlimeCore = 30
        }
    },
    LapisSlime = {
        Name = "Lapis Slime",
        Icon = "rbxassetid://16483649287",
        IdleAnim = "SlimeIdle",

        Drops = {
            SlimeGel = 60,
            SlimeCore = 40
        }
    },
    PurpleSlime = {
        Name = "Purple Slime",
        Icon = "rbxassetid://16483649160",
        IdleAnim = "SlimeIdle",

        Drops = {
            SlimeGel = 50,
            SlimeCore = 50
        }
    },
    CrimsonSlime = {
        Name = "Crimson Slime",
        Icon = "rbxassetid://17543155439",
        IdleAnim = "SlimeIdle",

        Drops = {
            CrimsonSlimeCore = 90,
            CrimsonSlimeFang = 10
        }
    },
}

AssetBook.BuffInfo = {
    AttackBuff = {
        Color = fromRGB(255, 255, 255),
        Icon = "rbxassetid://2965862892",
        Type = "Buff"
    },
    MagicBuff = {
        Color = fromRGB(255, 255, 255),
        Icon = "rbxassetid://2965863231",
        Type = "Buff"
    },
    Burn = {
        Color = fromRGB(255, 0, 0),
        Icon = "rbxassetid://12218488404",
        Type = "Debuff"
    },
    Poison = {
        Color = fromRGB(170, 85, 255),
        Icon = "rbxassetid://12371171272",
        Type = "Debuff"
    },
    SpeedBuff = {
        Color = fromRGB(0, 255, 255),
        Icon = "rbxassetid://2970816149",
        Type = "Buff"
    },
    DefenseBuff = {
        Color = fromRGB(128, 128, 128),
        Icon = "rbxassetid://4824422041",
        Type = "Buff"
    }
}

local default = {
    Ambient = fromRGB(127, 127, 127),
    OutdoorAmbient = fromRGB(198, 198, 198),
    FogColor = fromRGB(21, 152, 205),
    FogEnd = 2000
}
AssetBook.LocationInfo = {
    MonolithVillage = {
        Name = "Monolith Village",
        Desc = "Where story truly begins.",
        Music = "StoryBegins",
        MusicVolume = 1,
        RecommendLevel = 1,

        Lighting = default
    },
    MonolithGrove = {
        Name = "Monolith Grove",
        Desc = "",
        Music = "HiddenForest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    InitusBay = {
        Name = "Initus Bay",
        Desc = "",
        Music = "BraveAdventure",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    PrimisField = {
        Name = "Primis Field",
        Desc = "",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 5,

        Lighting = default
    },
    EnsisLake = {
        Name = "Ensis Lake",
        Desc = "",
        Music = "FarewayLand",
        MusicVolume = 1.5,
        RecommendLevel = 20,

        Lighting = default
    },
    VenatorVillage = {
        Name = "Venator Village",
        Desc = "",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    EnsisRiver = {
        Name = "Ensis River",
        Desc = "",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },

    NorthernStronghold = {
        Name = "Northern Stronghold",
        Desc = "",
        Music = "Stronghold",
        MusicVolume = 0.7,
        RecommendLevel = 150,

        Lighting = {}
    }
}

return AssetBook
