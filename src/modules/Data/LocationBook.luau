--!nocheck

local fromRGB = Color3.fromRGB

local default = {
    Ambient = fromRGB(127, 127, 127),
    OutdoorAmbient = fromRGB(198, 198, 198),
    FogColor = fromRGB(106, 185, 221),
    FogEnd = 2000
}
local tundra = {
    FogColor = fromRGB(0, 196, 255),
    FogEnd = 350,
    OutdoorAmbient = fromRGB(125, 125, 125)
}

local LocationBook = {
    MonolithVillage = {
        Name = "Monolith Village",
        Desc = "Where story truly begins",
        Music = "StoryBegins",
        MusicVolume = 1,
        RecommendLevel = 1,

        Lighting = default
    },
    MonolithGrove = {
        Name = "Monolith Grove",
        Desc = "Perhaps you cannot find your way out of this forest?",
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
        Desc = "Where your adventure begins in the past",
        Music = "BraveAdventure",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    PrimisField = {
        Name = "Primis Field",
        Desc = "Memories from the past flood into your mind",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 5,

        Lighting = default
    },
    EnsisLake = {
        Name = "Ensis Lake",
        Desc = "It could be said to be the habitat of Slimes",
        Music = "WorldAdventure",
        MusicVolume = 0.7,
        RecommendLevel = 20,

        Lighting = default
    },
    VenatorVillage = {
        Name = "Venator Village",
        Desc = "Fortunately, they have a path leading to another world",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    EnsisRiver = {
        Name = "Ensis River",
        Desc = "Where is the source of the river?",
        Music = "Conquest",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    NexusForest = {
        Name = "Nexus Forest",
        Desc = "It is unknown where this forest leads",
        Music = "WorldAdventure",
        MusicVolume = 0.7,
        RecommendLevel = 200,

        Lighting = {
            Ambient = fromRGB(),
            FogColor = fromRGB(170, 255, 255),
            FogEnd = 1000
        }
    },
    AlderTown = {
        Name = "Alder Town",
        Desc = "Legend has it that alchemists gather here",
        Music = "StepLegends",
        MusicVolume = 0.5,
        RecommendLevel = 1,

        Lighting = default
    },
    ArkusEnclave = {
        Name = "Arkus Enclave",
        Desc = "Who knows why there is an empty island here?",
        Music = "Skyventure",
        MusicVolume = 0.5,
        RecommendLevel = 170,

        Lighting = default
    },
    FirestoneIsland = {
        Name = "Firestone Island",
        Desc = "It seems to have the ability to evolve the power within one's heart",
        Music = "Skyventure",
        MusicVolume = 0.5,
        RecommendLevel = 170,

        Lighting = default
    },

    NiximEntrance = {
        Name = "Nixim Entrance",
        Desc = "Once you step through here, you'll be in the snowy plains",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 230,

        Evernight = true,

        Lighting = tundra
    },
    NiximCliff = {
        Name = "Nixim Cliff",
        Desc = "If you're not careful, you might fall into the abyss.",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 230,

        Evernight = true,

        Lighting = tundra
    },
    NiximForest = {
        Name = "Nixim Forest",
        Desc = "The snow blocks your view, making it difficult for you to discern objects...",
        Music = "Tundra",
        MusicVolume = 0.5,
        RecommendLevel = 230,

        Evernight = true,

        Lighting = tundra
    },
    NorthernStronghold = {
        Name = "Northern Stronghold",
        Desc = "It could be said that this is the last stronghold guarding the world",
        Music = "Stronghold",
        MusicVolume = 0.7,
        RecommendLevel = 1,

        Lighting = {
            Ambient = fromRGB(127, 127, 127),
            OutdoorAmbient = fromRGB(198, 198, 198),
            FogColor = fromRGB(106, 185, 221),
            FogEnd = 20000
        }
    }
}

return LocationBook
