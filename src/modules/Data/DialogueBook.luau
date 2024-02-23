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
            "EXIT Nothing else to ask, thanks.",

            Option1 = {
                "Long long ago, I summoned the first Savior, to maintain balance in Critical Dimension.",
                "But this tranquility proved finite. A being arose, it's about destruction, it was the Abyss.",
                "The Abyss hated life in any form, they were destroying the worlds.",
                "And Epic was one of the leaders in Abyss.",
                "CHOICE 1"
            },
            Option2 = {
                "Then just go ahead and do it.",
            },
        }
    },

    Extra = {}
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
        "Good luck, traveller!"
    },

    Else = {
        "What are you waiting for?",
        "CHOICE 1",

        Choice1 = {
            "Where is Monolith Grove?",
            "Why did you choose to be a protector?",
            "EXIT Nothing else to ask, thanks.",

            Option1 = {
                "Have you seen the entrance over there? Just keep walking along this path, and you'll reach it.",
                "CHOICE 1"
            },
            Option2 = {
                "Regardless, we are all working towards the same goal, aren't we? To seal the Abyss and protect this planet.",
                "CHOICE 1"
            },
            Option3 = {
                "Good luck then!"
            },
        }
    },

    Extra = {
        Main3 = "FirstStepTutorial"
    }
}

dialogues.Firefly = {
    Main5 = {
        "(Surprised) It's been a long time since I've seen a passing adventurer. Where are you from?",
        "CHOICE 1",

        Choice1 = {
            "Initus Village",
            "Arkus Enclave",

            Option1 = {
                "So why did you go out of the village? That's something I'm very curious about.",
                "CHOICE 2"
            },
            Option2 = {
                "Really? Judging by your attire, you don't seem to be from around there.",
                "CHOICE 1"
            }
        },
        Choice2 = {
            "Cuz I'm the Savior!",
            "I wanna adventure!",

            Option1 = {
                "Alright then, Well, it seems like another edgy teenager.",
                "CHOICE 2"
            },
            Option2 = {
                "Well, since you're so insistent, I'll point you in the right direction.",
                "Heading left will take you to Initus Bay, where you should be able to use the Sky Galleon to reach another location."
            }
        }
    },

    Else = {
        "Heading left will take you to Initus Bay, where you should be able to use the Sky Galleon to reach another location.",
        "CHOICE 1",

        Choice1 = {
            "I may have seen you before.",
            "EXIT Goodbye!",

            Option1 = {
                "That's not surprising. Perhaps you met me in another dimension.",
                "CHOICE 1"
            },
            Option2 = {
                "Good luck then!"
            }
        }
    },

    Extra = {}
}

dialogues.Hehe = {
    Main6 = {
        "Hi, adventurer! You seem to be in a hurry. Have you encountered any trouble?",
        "CHOICE 1",

        Choice1 = {
            "I'm looking for Sky Galleon.",
            "I want to level up!",

            Option1 = {
                "Have you seen the Sky Galleon docked over there? I guess that's what you're looking for.",
                "However, without Everfrost Seeds, you are not allowed to board it.",
                "CHOICE 2"
            },
            Option2 = {
                "If you wanna level up quickly, you can try to defeat those slimes in field.",
                "CHOICE 1"
            }
        },
        Choice2 = {
            "How do I get it?",
            "Is there another way?",

            Option1 = {
                "I heard that something happened in Monolith Grove, maybe you can get it there.",
            },
            Option2 = {
                "Perhaps not, I can't say for sure. Maybe you can try going to Misni Port?",
                "CHOICE 2"
            }
        }
    },

    Else = {
        "If you need me in the future, you can come find me. I'm quite certain we will meet again.",
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

    Extra = {}
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
    }
}

return dialogues
