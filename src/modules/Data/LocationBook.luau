--!nocheck

local fromRGB = Color3.fromRGB

local default = {
    Ambient = fromRGB(127, 127, 127),
    OutdoorAmbient = fromRGB(198, 198, 198),
    FogColor = fromRGB(106, 185, 221),
    FogEnd = 2000
}
local LocationBook = {
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
    },

    Baseplate = {
        Name = "Baseplate",
        Desc = "A testing place for devs only",
        Music = "Baseplate",
        MusicVolume = 0.6,
        RecommendLevel = 150,

        Lighting = default
    }
}

return LocationBook
