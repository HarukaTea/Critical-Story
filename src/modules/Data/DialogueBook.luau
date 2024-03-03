--!nocheck

local dialogues = {}

dialogues.Cyalm = {
    Main1 = {
        "You have finally awakened. Still not accustomed to this world, are you?",
        [[Let me introduce myself again. I am Cyalm from the <font color="#2ed573">Sky Empire</font>.]],
        [[I have detected the rise of sinister forces from the neighboring <font color="#2ed573">Critical Dimension</font>.]],
        "For certain reasons, I have decided to help this dimension. ",
        [[I am aware that you recently saved the <font color="#2ed573">Sky Empire</font>, but...]],
        [[This is a favor I ask of you. Here is the first stop on your journey: <font color="#1e90ff">Initus Village</font>.]],
        "Try talking with the villagers here.",
    },

    Main5 = {
        "It looks like you already have a rough understanding of this world.",
        [[I have some matters to attend to in the <font color="#2ed573">Sky Empire</font>. Be extra cautious while I'm away.]],
        [[One of <font color="#5352ed">the Abyss</font> members, <font color="#ff4757">Pahozinho</font>, seems to have been active recently.]]
    },

    Else = {
        "You still have other questions to ask?",
        "CHOICE 1",

        Choice1 = {
            "Where do these sinister forces come from?",
            "EXIT Nothing else to ask, thanks.",

            Option1 = {
                [[It seems to be an organization called <font color="#5352ed">Abyss</font>, led by <font color="#ff4757">Epic Critical</font>.]],
                [[I have a premonition that you will undoubtedly encounter members of <font color="#5352ed">Abyss</font> in your future travels.]],
                "When that time comes, you must be extra cautious.",
            },
            Option2 = {
                "No problem, good luck then!",
            },
        }
    },

    Extra = {}
}

dialogues.Milk = {
    Main2 = {
        "Hello, Adventurer! Wait...Is that the Critical Manipulator you're carrying?",
        [[Excellent...really excellent..., my dear, you will be the <font color="#ff4757">Savior</font> of this world.]],
        "I'm sorry to say, perhaps...you are the last Savior.",
        [[It's inevitable that we meet here, is it <font color="#ff4757">Cyalm</font> who brings you here?]],
        "My name is Edward Cole, a retired Protector, and you can call me Milk.",
        "Recently I discovered things forgotten that weigh heavy on the present.",
        [[Once upon a time, Cyalm summoned the first Savior, <font color="#ff4757">Pioxit</font>, to maintain balance of this world.]],
        [[But this tranquility proved finite. A being arose, it's about destruction, it was <font color="#5352ed">the Abyss</font>.]],
        "The Abyss hated life in any form, they were destroying this world, and nearby Dimensions.",
        "It fought to blot out all life, and would have succeeded, but for the sacrifice of the first Savior.",
        "He succeeded in sealing them away, and by doing so, he exhausted his power completely.",
        "Before its last energies dissipated, he gifted four artifacts to this world.",
        [[These four artifacts, when united, form the key that can open the gate to <font color="#5352ed">the Ruins</font>, where <font color="#5352ed">Abyss</font> is sealed.]],
        "The seal has started to weaken, and we must quickly reseal it!",
        "But before that, as you are new to this world, you might not be familiar with the combat here.",
        "In your realm, combat relies on targeting, but here, it's entirely different.",
        "Why not experience it firsthand? Merely hearing about it from me won't allow you to grasp its intricacies.",
        "Talk to me again when you are ready."
    },

    Main3 = {
        "There are a lot to be learned from combat, and this tutorial is no exception.",
        [[In Critical worlds, touch the glowing symbols and use your <font color="#ffa502">critical</font> power to attack.]],
        "Are you ready for the fight?",
        "CHOICE 1",

        Choice1 = {
            "Yes!",
            "Yes!",
            "Yes!",

            Option1 = { "Get ready to fight then!" },
            Option2 = { "Get ready to fight then!" },
            Option3 = { "Get ready to fight then!" },
        }
    },

    Main4 = {
        "Excellent! You may think it's trivial, but combat is an essential skill that will be pivotal in the future.",
        "I believe you have grasped the intricacies of it.",
        "In the journeys ahead, you should learn more, but for now, these should suffice.",
        "This world relies on you now, so go forth on your journey.",
        "Good luck!"
    },

    Else = {
        "I believe you have grasped the intricacies of it.",
        "In the journeys ahead, you should learn more, but for now, these should suffice.",
        "This world relies on you now, so go forth on your journey."
    },

    Extra = {
        Main3 = "FirstStepTutorial"
    }
}

dialogues.Hehe = {
    Main6 = {
        "Hi, adventurer! Welcome to Initus Bay!",
        "However, we've run into a bit of trouble... The road to Misni Port is blocked by Slimes.",
        "Their presence is disrupting the flow of goods between us and Misni Port. So, could you help us clear them out?",
        "CHOICE 1",

        Choice1 = {
            "Sure!",
            "Yep, it's another way to lvl up!",

            Option1 = {
                "That would be greatly appreciated. I'll be waiting here for your good news!"
            },
            Option2 = {
                "Yeah, even a level 950 adventuer will do it though.",
            }
        },
    },
    Main8 = {
        "Thank you so much! The danger on the way to Misni Port has been greatly reduced.",
        "If you wish to continue your adventure, that would be a good choice.",
        [[This is a letter of recommendation. Take it and look for <font color="#ff4757">MKK</font> at Misni Port. I believe she will treat you well.]]
    },

    Else = {
        "If you need me in the future, you can come here and find me.",
        "CHOICE 1",

        Choice1 = {
            "I feel like I've come here before.",
            "EXIT Thanks!",

            Option1 = {
                "Nothing too surprising, many adventurers have come here before and reached level 950. I believe you will be no exception.",
                "CHOICE 1"
            },
            Option2 = {
                "Wish you have a wonderful adventure!"
            }
        }
    },

    Extra = {
        Main8 = "CompletedInitusBay"
    }
}


--// Villagers
dialogues.FChenP = {
    ---// Monolith Grove
    Town1 = {
        "I guess you haven't completed it, right?"
    },
    Town2 = {
        "Great work! Thanks for helping!"
    },

    Else = {
        "Hi, adventurer, are you willing to accept my quest?",
        "CHOICE 1",

        Choice1 = {
            "What quest is that?",
            "EXIT I'm not ready.",

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
dialogues.Xiaotie = {
    --// Initus Village
    Else = {
        "How did you do that?",
        "I was just relaxing under this tree, and then you suddenly appeared..."
    }
}
dialogues.hnxtwyz = {
    --// Initus Village
    Else = {
        "Keep jumping will make you climb trusses more quickly.",
    }
}

return dialogues
