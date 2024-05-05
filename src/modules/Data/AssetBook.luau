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

AssetBook.ChatIcons = {
    Chat = "rbxassetid://13124035950",
    Exit = "rbxassetid://16458254833",
    Buy = "rbxassetid://16458319981",
    Craft = "rbxassetid://16458320089",
    Quest = "rbxassetid://16468992982"
}

AssetBook.PromptIcons = {
    Chat = "rbxassetid://13124035950",
    Quest = "rbxassetid://16468992982",
    Travel = "rbxassetid://16458254833"
}

AssetBook.ActionPanelIcons = {
    Attack = "rbxassetid://2034122114",
    Items = "rbxassetid://2228031606",
    Skills = "rbxassetid://2034172262",
    Defend = "rbxassetid://4601012009"
}

AssetBook.Classes = {
    "Warrior", "Archer", "Wizard",
    "Knight", "Rogue", "Repeater",
    "Striker", "Alchemist", "Illuionist"
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

AssetBook.MonsterIds = {
    SpikeFox = "Spike Fox",
    SpikeWolf = "Spike Wolf",
    ThornWolf = "Thorn Wolf",
    NeedleWolf = "Needle Wolf",
    LavaWolf = "Lava Wolf",

    GreenSlime = "Green Slime",
    BlueSlime = "Blue Slime",
    LapisSlime = "Lapis Slime",
    PurpleSlime = "Purple Slime",
    RockSlime = "Rock Slime"
}

AssetBook.MonsterAvatars = {
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

AssetBook.BuffImages = {
    AttackBuff = "rbxassetid://2965862892",
    MagicBuff = "rbxassetid://2965863231",
    Burn = "rbxassetid://12218488404",
    Poison = "rbxassetid://12371171272",
    Speed = "",
    Jump = ""
}

AssetBook.BuffColors = {
    AttackBuff = fromRGB(255, 255, 255),
    MagicBuff = fromRGB(255, 255, 255),
    Burn = fromRGB(255, 0, 0),
    Poison = fromRGB(170, 85, 255)
}

AssetBook.LocationInfo = {
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

return AssetBook
