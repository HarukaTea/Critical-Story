--!nocheck
--!optimize 2
--!native

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

AssetBook.ActionPanelIcons = {
    Attack = "rbxassetid://2034122114",
    Items = "rbxassetid://2228031606",
    Skills = "rbxassetid://2034172262",
    Defend = "rbxassetid://4601012009"
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
local tundra = {
    Ambient = fromRGB(),
    OutdoorAmbient = fromRGB(128, 128, 128),
    FogColor = fromRGB(0, 196, 255),
    FogEnd = 350
}
AssetBook.LocationInfo = {
    InitusBay = {
        Name = "Initus Bay",
        Desc = "The start of every adventure...",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    PrimisField = {
        Name = "Primis Field",
        Desc = "Still filled with fond memories...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    ThyrsusForest = {
        Name = "Thyrsus Woods",
        Desc = "In the tranquil forest, all you can hear is the howling of wolves.",
        Music = "Conquest",
        MusicVolume = 0.6,
        RecommendLevel = 10,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    AlderForest = {
        Name = "Alder Forest",
        Desc = "The trees in this forest seem a bit peculiar.",
        Music = "Conquest",
        MusicVolume = 0.6,
        RecommendLevel = 35,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    EnsisLake = {
        Name = "Ensis Lake",
        Desc = "If only there were a way to get to the center...",
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
    EnsisCave = {
        Name = "Ensis Cave",
        Desc = "Ghosts make you crazy!",
        Music = "RoadTaken",
        MusicVolume = 0.5,
        RecommendLevel = 70,

        Lighting = {
            Ambient = fromRGB(),
            OutdoorAmbient = fromRGB(),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    Highlands = {
        Name = "Highlands",
        Desc = "I'd rather not fight these Slimes...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 30,

        Lighting = default
    },
    VenatorVillage = {
        Name = "Venator Village",
        Desc = "The inevitable path to the snowy plains",
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
        RecommendLevel = 15,

        Lighting = default
    },
    ClockTown = {
        Name = "Clock Town",
        Desc = "The bell tolls, echoing the ancient past.",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    AlderTown = {
        Name = "Alder Town",
        Desc = "The birthplace of the Alchemist.",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    NiximEntrance = {
        Name = "Nixim Village",
        Desc = "The gateway to the snowy wilderness.",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 40,

        Lighting = tundra
    },
    NiximCliff = {
        Name = "Nixim Cliff",
        Desc = "A moment's inattention could lead to a precipitous fall into the abyss...",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 45,

        Lighting = tundra
    },
    NiximForest = {
        Name = "Nixim Forest",
        Desc = "The vast white forest hides dangers that you might not detect.",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 50,

        Lighting = tundra
    },
    NorthernStronghold = {
        Name = "Northern Stronghold",
        Desc = "Facing the Abyss, this is the warriors' last stand.",
        Music = "Stronghold",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    AuraIsland = {
        Name = "Aura Islands",
        Desc = "Why is there a solitary island in the vast ocean?",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 55,

        Lighting = default
    },
    FirestoneIsland = {
        Name = "Firestone Islands",
        Desc = "The resolve of the warrior!",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 60,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 10000
        }
    }
}

return AssetBook
