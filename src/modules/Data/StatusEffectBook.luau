--!nocheck

local fromRGB = Color3.fromRGB

local StatusEffects = {}

StatusEffects.BuffInfo = {
    AttackBuff = {
        Color = fromRGB(255, 255, 255),
        Icon = "rbxassetid://2965862892",
        Type = "Buff"
    },
    MagicBuff = {
        Color = fromRGB(255, 255, 255),
        Icon = "rbxassetid://2965863231",
        Type = "Buff"
    },
    Burn = {
        Color = fromRGB(255, 0, 0),
        Icon = "rbxassetid://12218488404",
        Type = "Debuff"
    },
    Poison = {
        Color = fromRGB(170, 85, 255),
        Icon = "rbxassetid://12371171272",
        Type = "Debuff"
    },
    SpeedBuff = {
        Color = fromRGB(0, 255, 255),
        Icon = "rbxassetid://2970816149",
        Type = "Buff"
    },
    DefenseBuff = {
        Color = fromRGB(128, 128, 128),
        Icon = "rbxassetid://4824422041",
        Type = "Buff"
    },
    HealBuff = {
        Color = Color3.fromHex('#00e676'),
        Icon = "rbxassetid://12027131895",
        Type = "Buff"
    },
    ManaBuff = {
        Color = fromRGB(0, 255, 255),
        Icon = "rbxassetid://12158006954",
        Type = "Buff"
    }
}

return StatusEffects
