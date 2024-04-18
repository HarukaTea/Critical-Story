--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)

local story = {}

local v3New = Vector3.new

local pos = ClientUtil:GetKeyStoryLocations()

story.Main = {
    {
        Name = "The Beginning", -- 1
        Target = "Talk to Cyalm",
        Desc = "",
        NPC = "Cyalm",
        Hint = if pos.Cyalm then pos.Cyalm else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Valiant Explorer", -- 2
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
        Name = "First Step", -- 3
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
        Name = "The Future", -- 4,
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
        Name = "The Abyss - Paho", -- 5
        Target = "Talk to Cyalm again",
        Desc = "",
        NPC = "Cyalm",
        Hint = if pos.Cyalm then pos.Cyalm else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Initus Bay", -- 6
        Target = "Start your adventure!",
        Desc = "",
        NPC = "Hehe",
        Hint = if pos["Initus Bay"] then pos["Initus Bay"].StoryLocator1 else v3New(),

        Rewards = {
            EXP = 30,
            Gold = 200
        }
    },
    {
        Name = "Slime Troubles", -- 7
        Target = "Defeat Slimes to reach Level 10",
        Desc = "",
        NPC = "None",
        Hint = if pos["Primis Field"] then pos["Primis Field"].StoryLocator1 else v3New(),

        Script = true,

        Rewards = {
            EXP = 40,
            Gold = 200
        }
    },
    {
        Name = "The Next Journey", -- 8
        Target = "Talk to hehe again",
        Desc = "",
        NPC = "Hehe",
        Hint = if pos.Hehe then pos.Hehe else v3New(),

        Rewards = {
            EXP = 30,
            Gold = 200
        }
    },
    {
        Name = "Misni Port", --- 9
        Target = "Coming Soon",
        Desc = "",
        NPC = "None",
        Hint = v3New(),

        Rewards = {
            EXP = 100,
            Gold = 300
        }
    },
}

story.Side = {
    {
        Name = "New Critical Power",
        Target = "Get Archer class from its statue",
        Desc = "",
        NPC = "None",
        Hint = if pos.Archer then pos.Archer else v3New(),

        Script = true,

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    }
}

story.Town = {
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

story.NPCs = {
    Cyalm = "Cyalm",
    Milk = "Milk",
    Firefly = "Firefly",
    Hehe = "Hehe",

    FChenP = "FChenP",
    Xiaotie = "Xiaotie",
    hnxtwyz = "hnxtwyz"
}

return story
