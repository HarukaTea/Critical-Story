--!nocheck

local fromRGB = Color3.fromRGB

local ClassBook = {}

ClassBook.ClassInfo = {
	Warrior = {
		Image = "rbxassetid://2965862892",
		Color = fromRGB(255, 100, 100),
        Type = "DMG",
        Order = 1,
        Desc = "A world is waiting for you, a hero who will change the world.",

        Talents = {
            [1] = {
                Id = "WarriorDash",
                Name = "WARRIOR DASH",
                Desc = "<blue>Dash</font> for a short distance forward, gain Shield",

                Materials = {
                    [1] = {
                        Id = "SlimeCore",
                        Amount = 10
                    },
                    [2] = {
                        Id = "SlimeGel",
                        Amount = 10
                    }
                }
            }
        }
	},
	Archer = {
		Image = "rbxassetid://2965863905",
		Color = fromRGB(100, 255, 100),
        Type = "DMG",
        Order = 2,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Wizard = {
		Image = "rbxassetid://2965863231",
		Color = fromRGB(100, 100, 254),
        Type = "Magic",
        Order = 3,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Knight = {
		Image = "rbxassetid://2965863677",
		Color = fromRGB(255, 255, 50),
        Type = "DMG",
        Order = 4,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Rogue = {
		Image = "rbxassetid://12284961892",
		Color = fromRGB(255, 170, 255),
        Type = "DMG",
        Order = 5,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Repeater = {
		Image = "rbxassetid://12190533959",
		Color = fromRGB(65, 179, 255),
        Type = "DMG",
        Order = 6,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Striker = {
		Image = "rbxassetid://12190535870",
		Color = fromRGB(253, 148, 44),
        Type = "DMG",
        Order = 7,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Alchemist = {
		Image = "rbxassetid://12236618949",
		Color = fromRGB(43, 188, 93),
        Type = "Magic",
        Order = 8,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
	Illusionist = {
		Image = "rbxassetid://15875390788",
		Color = fromRGB(0, 255, 252),
        Type = "Magic",
        Order = 9,
        Desc = "A world is waiting for you, a hero who will change the world."
	},
    Juggernaut = {
        Image = "rbxassetid://16654290906",
        Color = fromRGB(253, 148, 44),
        Type = "DMG",
        Order = 10,
        Desc = "A world is waiting for you, a hero who will change the world."
    },
    Reaper = {
        Image = "rbxassetid://17667241921",
        Color = fromRGB(163, 39, 39),
        Type = "DMG",
        Order = 11,
        Desc = "A world is waiting for you, a hero who will change the world."
    },
    WindDancer = {
        Image = "rbxassetid://18423401512",
        Color = Color3.fromHex('#70a1ff'),
        Type = "DMG",
        Order = 12,
        Desc = "A world is waiting for you, a hero who will change the world."
    }
}

return ClassBook
