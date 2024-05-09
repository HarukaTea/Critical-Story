local Lighting = game:GetService("Lighting")
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
        Icon = "rbxassetid://13886503379"
    },
    LavaWolf = {
        Name = "Lava Wolf",
        Icon = "rbxassetid://13886503379"
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

AssetBook.LocationInfo = {
    InitusBay = {
        Name = "Initus Bay",
        Desc = "The start of every adventure...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    PrimisField = {
        Name = "Primis Field",
        Desc = "The memory of Slimes...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    ThyrsusForest = {
        Name = "Thyrsus Forest",
        Desc = "Pretty Quiet, you can only hear the sound from wolves...",
        Music = "NeptuneValley",
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
        Desc = "There's something peculiar about the trees in this forest...",
        Music = "NeptuneValley",
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
        Desc = "If there is a way to reach the center...",
        Music = "FarewayLand",
        MusicVolume = 1.5,
        RecommendLevel = 20,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
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
        Desc = "A pretty boring place...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 30,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    VenatorVillage = {
        Name = "Venator Village",
        Desc = "The inevitable path to Tundra...",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    EnsisRiver = {
        Name = "Ensis River",
        Desc = "The origin of a river: where does it truly begin?",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    ClockTown = {
        Name = "Clock Town",
        Desc = "Chimes represent the ancient past...",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
    AlderTown = {
        Name = "Clock Town",
        Desc = "Chimes represent the ancient past...",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(21, 152, 205),
            FogEnd = 2000
        }
    },
}

return AssetBook
