--!strict
--!optimize 2
--!native

return {
    --- Stats
    Magic = 0,
    Mana = 0,
    MinDMG = 5,
    MaxDMG = 15,
    MaxMana = 0,
    MaxShield = 0,
    OrbLifeTime = 10,
    Shield = 0,

    --- States
    Repairing = false,
    Healing = false,
    HitCD = 0,
    InCombat = false,

    --- Buffes
    HealthBuff = 0,
    JumpBuff = 0,
    MagicBuff = 0,
    ManaBuff = 0,
    MinDMGBuff = 0,
    MaxDMGBuff = 0,
    ShieldBuff = 0,
    SpeedBuff = 0,
    RestoreBuff = 15,
    HealBuff = 10,

    BurnChance = 0,
    DodgeChance = 0,
    CriChance = 1,

    --- Class stats
    Combo = 0,
    Arrows = 0,
    WizardCasted = 0,
    Guard = 0,
    RogueCritical = 0
}
