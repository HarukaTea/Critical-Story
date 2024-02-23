--!nocheck

local story = {}

local maps = workspace:WaitForChild("Maps") :: Folder
local npcs = workspace:WaitForChild("MapComponents").NPCs :: Folder
local statues = workspace.MapComponents.Statues :: Folder

local v3New = Vector3.new

story.Main = {
    {
        Name = "The Beginning", -- 1
        Target = "Talk to Cyalm",
        Desc = "",
        NPC = "Cyalm",
        Hint = if npcs:FindFirstChild("Cyalm") then npcs.Cyalm.PrimaryPart.Position else v3New(),

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
        Hint = if npcs:FindFirstChild("Milk") then npcs.Milk.PrimaryPart.Position else v3New(),

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
        Hint = if npcs:FindFirstChild("Milk") then npcs.Milk.PrimaryPart.Position else v3New(),

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
        Hint = if npcs:FindFirstChild("Milk") then npcs.Milk.PrimaryPart.Position else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Monolith Grove",
        Target = "Start your adventure!",
        Desc = "",
        NPC = "Firefly",
        Hint = maps["Monolith Grove"].StoryLocator1.Position,

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "To the Sky",
        Target = "Go to Initus Bay",
        Desc = "",
        NPC = "Hehe",
        Hint = maps["Initus Bay"].StoryLocator1.Position,

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "The Secret",
        Target = "Go back to Monolith Grove",
        Desc = "",
        NPC = "None",
        Hint = maps["Monolith Grove"].StoryLocator1.Position,

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
}

story.Side = {
    {
        Name = "New Trust Power",
        Target = "Get Archer power from its statue",
        Desc = "",
        NPC = "None",
        Hint = if statues:FindFirstChild("Archer") then statues.Archer.PrimaryPart.Position else v3New(),

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
        NPC = "None",
        Hint = v3New(),

        Script = true,

        Rewards = {}
    },
    {
        Name = "Fox Hunt",
        Target = "Return to FChenP",
        Desc = "",
        NPC = "FChenP",
        Hint = if npcs:FindFirstChild("FChenP") then npcs.FChenP.PrimaryPart.Position else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    }
}

story.NPCs = {
    Cyalm = "Cyalm",
    Milk = "Milk",
    FChenP = "FChenP",
    Firefly = "Firefly",
    Hehe = "Hehe"
}

return story
