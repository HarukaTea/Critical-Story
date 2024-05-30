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
        Target = "Talk to Pioxit again",
        Desc = "",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {}
    },
    {
        Name = "Valiant Explorer",
        Target = "Talk to Milk",
        Desc = "",
        NPC = "Milk",
        Hint = if pos.Milk then pos.Milk else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Critical Power",
        Target = "Learn how to combat",
        Desc = "",
        NPC = "Milk",
        Hint = if pos.Milk then pos.Milk else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "The Future",
        Target = "Talk to Milk again",
        Desc = "",
        NPC = "Milk",
        Hint = if pos.Milk then pos.Milk else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Paho - The Executor",
        Target = "Talk to Pioxit again",
        Desc = "",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Initus Bay",
        Target = "Start your adventure!",
        Desc = "",
        NPC = "Hehe",
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

        Script = true,

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
