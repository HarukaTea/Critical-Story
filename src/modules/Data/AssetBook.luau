--!nocheck

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

local AssetBook = {}

AssetBook.TweenInfos = {
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
    three = newTweenInfo(3),
    four = newTweenInfo(4),
	six = newTweenInfo(6),
    fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}

AssetBook.TierColor = {
	Common = fromRGB(0, 255, 0),
	Rare = fromRGB(49, 226, 236),
	Epic = fromRGB(214, 96, 253),
	Ultra = fromRGB(250, 250, 65),
	Mythic = fromRGB(255, 22, 57),
}

AssetBook.TypeColor = {
	Active = fromRGB(255, 170, 127),
	Passive = fromRGB(99, 244, 9),
	Material = fromRGB(0, 222, 238),
	Cosmetic = fromRGB(170, 85, 255),
	Quest = fromRGB(46, 213, 115),
}

AssetBook.QuestColor = {
    Main = fromRGB(46, 213, 115),
    Side = fromRGB(255, 165, 2),
    Town = fromRGB(255, 107, 129)
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
		Color = fromRGB(0, 255, 22),
        Type = "Magic"
	},
	Illusionist = {
		Image = "rbxassetid://15875390788",
		Color = fromRGB(0, 255, 252),
        Type = "Magic"
	}
}

AssetBook.MonsterInfo = {
    SpikeFox = {
        Name = "Spike Fox",
        Icon = "rbxassetid://13886503379"
    },
    SpikeWolf = {
        Name = "Spike Wolf",
        Icon = "rbxassetid://16483664838"
    },
    ThornWolf = {
        Name = "Thorn Wolf",
        Icon = "rbxassetid://15688333545"
    },
    HardmodeWolf = {
        Name = "Hardmode Wolf",
        Icon = "rbxassetid://15688333545"
    },
    ElderWolf = {
        Name = "Elder Wolf",
        Icon = ""
    },

    Kitsune = {
        Name = "Kitsune",
        Icon = ""
    },
    Stalker = {
        Name = "Stalker",
        Icon = ""
    },

    GreenSlime = {
        Name = "Green Slime",
        Icon = "rbxassetid://15951815518"
    },
    LapisSlime = {
        Name = "Lapis Slime",
        Icon = "rbxassetid://16483649287"
    },
    PurpleSlime = {
        Name = "Purple Slime",
        Icon = "rbxassetid://16483649160"
    },
    CrimsonSlime = {
        Name = "Crimson Slime",
        Icon = ""
    },
    IceSlime = {
        Name = "Ice Slime",
        Icon = ""
    }
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
        Type = "Debuff"
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
        Desc = "The start of your story",
        Music = "StoryBegins",
        MusicVolume = 0.7,
        RecommendLevel = 1,

        Lighting = default
    },
    MonolithGrove = {
        Name = "Monolith Grove",
        Desc = "Where can I find the way out?",
        Music = "HiddenForest",
        MusicVolume = 0.7,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    InitusBay = {
        Name = "Initus Bay",
        Desc = "The start of your adventure",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    PrimisField = {
        Name = "Primis Field",
        Desc = "Great place for slimes",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 5,

        Lighting = default
    },
    ThyrsusForest = {
        Name = "Thyrsus Woods",
        Desc = "All you can hear is the howling of wolves",
        Music = "Conquest",
        MusicVolume = 0.6,
        RecommendLevel = 40,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    EnsisLake = {
        Name = "Ensis Lake",
        Desc = "Is there a way to get to the center?",
        Music = "FarewayLand",
        MusicVolume = 1.5,
        RecommendLevel = 20,

        Lighting = default
    },
    SonusCave = {
        Name = "Sonus Cave",
        Desc = "Bats make you crazy!",
        Music = "RoadTaken",
        MusicVolume = 0.5,
        RecommendLevel = 5,

        Lighting = {
            Ambient = fromRGB(),
            OutdoorAmbient = fromRGB(),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    Highlands = {
        Name = "Highlands",
        Desc = "I'd rather not fight these annoying slimes",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 30,

        Lighting = default
    },
    VenatorVillage = {
        Name = "Venator Village",
        Desc = "The inevitable path to snowy world",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    EnsisRiver = {
        Name = "Ensis River",
        Desc = "Where does the river truly originate?",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    }
}

return AssetBook
