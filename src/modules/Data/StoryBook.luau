--!nocheck

local story = {}

local npcs = workspace:WaitForChild("MapComponents").NPCs :: Folder

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
        Target = "See what happened there",
        Desc = "",
        NPC = "None",
        Hint = v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    }
}

story.Side = {
    {
        Name = "New Trust Power",
        Target = "Get Archer power from its statue",
        Desc = "",
        NPC = "None",
        Hint = v3New(5, 5, 5),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    }
}

story.Town = {
    {
        Name = "Slime Troubles",
        Target = "Defeat 5 slimes",
        Desc = "",
        Hint = v3New()
    }
}

story.NPCs = {
    Cyalm = "Cyalm",
    Milk = "Milk"
}

return story
