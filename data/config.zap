
opt client_output = "../src/modules/Data/Events.luau"
opt server_output = "../src/server/Modules/Data/ServerEvents.luau"

event AddPoints = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Target: string,
        Points: u16?
    }
}
event BuyItem = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ItemId: string,
        Amount: u16
    }
}
event CombatStart = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Locator: Instance (BasePart)?
    }
}
event CreateHint = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        Hint: string(..666),
        Option: string(..10)?
    }
}
event ClientTween = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Objs: Instance[]?,
        Goal: unknown,
        TweenInfo: string,
        UseHarukaTween: boolean?
    }
}
event ChangePlayerSetting = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        SettingId: string,
    }
}
event ChangePlayerClass = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ClassId: string,
    }
}
event ChangeAttackTarget = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Target: Instance (Model)?
    }
}
event PlayerTakeDMG = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Projectile: Instance?
    }
}
event ChangePlayerLocation = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        LocationId: string(..100)
    }
}
event EquipItem = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ItemType: string,
        ItemSlot: string,
        ItemId: string
    }
}
event EquipItemServer = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        ItemSlot: string,
        ItemId: string
    }
}
event EnterShopping = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        Items: string[]
    }
}
event ItemCD = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        Cooldown: u8,
        ItemId: string
    }
}
event ForceReset = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {}
}
event CameraScene = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Part: Instance (BasePart)?
    }
}
event ChestUnlocked = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Chest: Instance (Model)?,
    }
}
event GiveDrop = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        ItemId: string,
        Amount: u16,
        IsNew: boolean
    }
}
event MonsterTakeDMG = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Orb: Instance (Model)?
    }
}
event EnterNPCChat = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        NPC: Instance (Model)?
    }
}
event NPCChatEnded = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        NPC: Instance (Model)?,
        Series: string?
    }
}
event NewQuest = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        NPC: Instance (Model)?,
        Series: string,
        QuestId: u8
    }
}
event PlaySound = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Sound: Instance (Sound)?,
        TimePos: u16?
    }
}
event PlaySoundServer = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Sound: Instance (Sound)?,
        Origin: Vector3
    }
}
event PlayAnimation = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        AnimId: string
    }
}
event RejoinRequest = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {}
}
event FireStoryEvents = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        EventSymbol: string
    }
}
event UseItem = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ItemId: string
    }
}
event UpdatePinnedItem = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ItemId: string
    }
}