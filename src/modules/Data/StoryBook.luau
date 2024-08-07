--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)

local StoryBook = {}

local v3New = Vector3.new

local pos = ClientUtil:GetKeyStoryLocations()

StoryBook.Main = {
    {
        Name = "The Beginning",
        Target = "Learn more about <blue>Critical Realm</font>",
        Desc = "When you wake up, you find yourself in another world. It is quite evident that <blue>a brand new adventure</font> is waiting for you.",
        NPC = "Pioxit1",
        Hint = v3New(),

        Rewards = {
            EXP = 20,
            Gold = 200
        }
    },
    {
        Name = "First Steps",
        Target = "Talk to <blue>Pioxit</font>",
        Desc = "Then, go forward, for it seems you have no other choice, do you?",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {}
    },
    {
        Name = "Valiant Explorer",
        Target = "Talk to <blue>any villagers</font> here",
        Desc = "Are there really people in this <blue>dense valley</font>?",
        NPC = "None",
        Hint = if pos.MonolithVillage then pos.MonolithVillage.StoryLocator1 else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Critical Power",
        Target = "Go back to <blue>Pioxit</font>",
        Desc = "It seems this world still holds other secrets, waiting for you to <blue>explore</font>...",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "The Future",
        Target = "Talk to <blue>Pioxit</font> again",
        Desc = "Now, it's time to embark on your own <yellow>story</font>.",
        NPC = "Pioxit",
        Hint = if pos.Pioxit then pos.Pioxit else v3New(),

        Rewards = {
            EXP = 20,
            Gold = 100
        }
    },
    {
        Name = "Encounter",
        Target = "Coming Soon",
        Desc = "<red>Pioxit</font> has mentioned there would be danger... but never mind, let's get through this <blue>grove</font> and find the village first.",
        NPC = "None",
        Hint = v3New(),

        Rewards = {
            EXP = 30,
            Gold = 200
        }
    },
}

StoryBook.Side = {
    ---
}

StoryBook.Town = {
    ---
}

return StoryBook
