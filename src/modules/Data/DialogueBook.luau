--!nocheck

local DialogueBook = {}

DialogueBook.Pioxit1 = {
    Main1 = {
        "Hi, I'm <blue>Pioxit</font>, the <yellow>savior</font> of this dimension.",
        "The dimension is composed of countless worlds that share an underlying essence yet appear distinct.",
        "which I term: <yellow>The Critical Dimension</font>.",
        "Long long ago, an evil force emerged in this dimension.",
        "Among them, the most prominent is <purple>The Abyss</font> led by <purple>Epic</font>.",
        "They brought disasters to the dimension, causing some worlds to perish, vanishing into the river of history.",
        "Many heroes began their struggle, writing down epic and moving stories in their world.",
        "I'm also one of them. In the end, we defeated some members of <purple>The Abyss</font> and sealed them away.",
        "And now, as the seal begins to weaken, the remnants of The Abyss are planning a comeback.",
        "The Toucan branch, led by <purple>Calex</font>, has already stirred up turmoil in some worlds.",
        "My remaining power is not enough to reinforce the seal. Therefore, I need your help.",
        "CHOICE 1",

        Choice1 = {
            "I will try my best.",

            Option1 = { "Great, I believe you can do it!" }
        }
    },

    Else = {
        "Well I guess you are definitely cheating now lol",
    },

    Extra = {
        Main1 = "StoryMain1"
    }
}

DialogueBook.Pioxit = {
    Main2 = {
        "You have finally awakened. Still not accustomed to this world, are you?",
        "Here is the first stop on your journey: <blue>Monolith Village</font>.",
        "Let's start by talking with the people nearby."
    },

    Main4 = {
        "There are a lot to be learned from combat, and this tutorial is no exception.",
        "As you are new to this world, you might not be familiar with the combat here.",
        "In your realm, combat relies on <yellow>STRIKE</font>, but here, it's entirely different.",
        "Why not experience it firsthand? Merely hearing about it from me won't allow you to grasp its intricacies.",
        [[In Critical worlds, touch the glowing symbols and use your <yellow>critical</font> power to attack.]],
        "Are you ready for the fight?",
        "CHOICE 1",

        Choice1 = {
            "Yes!",

            Option1 = { "Get ready to fight then!" },
        }
    },

    Main5 = {
        "Excellent! You may think it's trivial, but combat is an essential skill that will be pivotal in the future.",
        "I believe you have grasped the intricacies of it.",
        "In the journeys ahead, you should learn more, but for now, these should suffice.",
        "This world relies on you now, so go forth on your journey.",
        [[I have some matters to attend to in the <blue>STRIKE world</font>. Be extra cautious while I'm away.]],
        [[One of <purple>the Abyss</font> members, <font color="#ff4757">Pahozinho</font>, seems to have been active recently.]],
        "When that time comes, you must be extra cautious."
    },

    Else = {
        "You still have other questions to ask?",
        "CHOICE 1",

        Choice1 = {
            "What's your plan next?",
            "EXIT Nothing else to ask, thanks.",

            Option1 = {
                [[I have a premonition that you will undoubtedly encounter members of <purple>Abyss</font> in your future travels.]],
                "When that time comes, you must be extra cautious.",
            },
            Option2 = {
                "No problem, good luck then!",
            },
        }
    },

    Extra = {
        Main4 = "FirstStepTutorial"
    }
}

--// Town
DialogueBook.FChenP = {
    ---// Monolith Grove
    Town1 = {
        "I guess you haven't completed it, right?"
    },
    Town2 = {
        "Great work! Thanks for the help!"
    },

    Else = {
        "Hi, explorer, could you do me a favor?",
        "CHOICE 1",

        Choice1 = {
            "Sure, what is that?",
            "EXIT Sorry, I'm not ready right now.",

            Option1 = {
                "The quest is simple, can you bring 6 Spiky Fur?",
                "CHOICE 2"
            },
            Option2 = {
                "Sure, you can come back whenever you want."
            }
        },
        Choice2 = {
            "QUEST Sure, I'll do it.",
            "EXIT I have something else to do.",

            Option1 = {
                "Alright, I'll wait for you, good luck then!",
                "QUEST TOWN 1"
            },
            Option2 = {
                "Sure, you can come back whenever you want."
            }
        }
    },

    Extra = {
        Town2 = "FChenPTown2"
    }
}


--// Villagers
DialogueBook.Xiaotie = {
    Main3 = {
        "I was relaxing under this tree, and then you just suddenly appeared...",
        "How did you do that?"
    },
    Else = {
        "I was relaxing under this tree, and then you just suddenly appeared..."
    },

    Extra = {}
}
DialogueBook.Paho = {
    Main6 = {
        "You are finally here...are you?",
        "blah blah blah",
        "blah blah blah"
    },

    Else = {
        "We will definitely meet again in the future...",
        "in the...futu...."
    },

    Extra = {
        Main6 = "PahoFight1"
    }
}
DialogueBook.Fallen1 = {
    Main3 = {
        "Any interested? We have apples, golden apples, and ice candies."
    },
    Else = {
        "Any interested? We have apples, golden apples, and ice candies."
    },

    Extra = {}
}

return DialogueBook
