--!nocheck

local dialogues = {}

dialogues.Cyalm = {
    Main1 = {
        "Looks like you are finally awake...",
        "Hello, my name is Cyalm. And it's me that summon you to this world.",
        "Our world is full of Chaos, and I believe you are the next savior who can banish the evil.",
        "Our first savior has sacrificed himself to defeat Epic.",
        "But a new evil called Toucan has been discovered, we need another savior to save Critical Dimensions.",
        "You need to collect Artifact that scattered in different worlds to increase your trust power.",
        "Your first adventure starts here, Initus Village.",
        "The world is counting on you, I know you can do it, right?"
    },

    Else = {
        "You still have many questions to ask?",
        "CHOICE 1",

        Choice1 = {
            "Who is Epic?",
            "What should I do next?",
            "EXIT Nothing else to ask, thanks.",

            Option1 = {
                "Long long ago, I summoned the first Savior, to maintain balance in Critical Dimension.",
                "But this tranquility proved finite. A being arose, it's about destruction, it was the Abyss.",
                "The Abyss hated life in any form, they were destroying the worlds.",
                "And Epic was one of the leaders in Abyss.",
            },
            Option2 = {
                "My suggestion is, fight some Slimes to start your journey.",
            },
            Option3 = {
                "Then just go ahead and do it."
            },
        }
    },
}

dialogues.Milk = {
    Main2 = {
        "Hello, Adventurer! Wait...Is that the Trust Manipulator you're carrying?",
        "Excellent, you are our savior.",
        "I'm sorry to say, perhaps...you are the last Savior.",
        "It's inevitable that we meet here, is it Cyalm who brings you here?",
        "My name is Edward Cole, a retired Protector, and you can call me Milk.",
        "Recently I discovered things forgotten that weigh heavy on the present.",
        "Once upon a time, Cyalm summoned the first Savior, it maintained balance in Critical Dimension.",
        "But this tranquility proved finite. A being arose, it's about destruction, it was the Abyss.",
        "The Abyss hated life in any form, they were destroying the worlds.",
        "It fought to blot out all life, and would have succeeded, but for the sacrifice of the first Savior.",
        "He succeeded in sealing them away, and by doing so, he exhausted his power completely.",
        "Before its last energies dissipated, he gifted four artifacts to different critical worlds.",
        "These four artifacts, when united, form the key that can open the gate to the Abyss.",
        "This is a lot to take in dear, and a huge request to make of you...",
        "The world is counting on you. I believe you can do it.",
        "But before you start adventure, I'll teach you how to combat.",
        "Talk to me again when you are ready.",
    },

    Main3 = {
        "There are a lot to be learned from combat, and this tutorial is no exception.",
        "Touch the glowing symbols and use your trust power to attack.",
        "Simple, right? But practice makes perfect. Get ready to fight!"
    },

    Main4 = {
        "Excellent! You may think it's trivial, but combat is an essential skill that will be pivotal in the future.",
        "And I guess you have the ability to start the adventure.",
        "I heard that something happened in Monolith Grove recently.",
        "So I think you can set this as the first stop on your adventure.",
        "Good luck, brave protector!"
    },

    Else = {
        "What are you waiting for?"
    },

    Extra = {
        Main3 = "FirstStepTutorial"
    }
}

return dialogues
