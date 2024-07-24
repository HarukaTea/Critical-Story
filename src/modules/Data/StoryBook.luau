--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)

local StoryBook = {}

local v3New = Vector3.new

local pos = ClientUtil:GetKeyStoryLocations()

StoryBook.Main = {
    {
        Name = "The Beginning",
        Target = "Learn more about this world",
        Desc = "",
        NPC = "Pioxit1",
        Hint = v3New(),

        Rewards = {
            EXP = 20,
            Gold = 200
        }
    },
    {
        Name = "First Steps",
        Target = "Talk to Pioxit",
        Desc = "",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {}
    },
    {
        Name = "Valiant Explorer",
        Target = "Talk to any villagers here",
        Desc = "",
        NPC = "None",
        Hint = if pos.MonolithVillage then pos.MonolithVillage.StoryLocator1 else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Critical Power",
        Target = "Go back to Pioxit",
        Desc = "",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "The Future",
        Target = "Talk to Pioxit",
        Desc = "",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Encounter",
        Target = "Find a way to Initus Bay",
        Desc = "",
        NPC = "None",
        Hint = v3New(),

        Rewards = {
            EXP = 30,
            Gold = 200
        }
    },
}

StoryBook.Side = {
    {
        Name = "Faction",
        Target = "Coming soon",
        Desc = "",
        NPC = "None",
        Hint = v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    }
}

StoryBook.Town = {
    {
        Name = "Fox Hunt",
        Target = "Get 6 Spiky Fur",
        Desc = "",
        NPC = "FChenP",
        Hint = v3New(),

        Script = true,

        Rewards = {}
    },
    {
        Name = "Fox Hunt",
        Target = "Return to FChenP",
        Desc = "",
        NPC = "FChenP",
        Hint = if pos.FChenP then pos.FChenP else v3New(),

        Rewards = {
            EXP = 40,
            Gold = 150
        }
    }
}

return StoryBook
