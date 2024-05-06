--!nocheck
--!optimize 2
--!native

return {
    --- Stats
    MinDMG = 0,
    MaxDMG = 0,
    Magic = 0,
    TP = 0,
    Shield = 0,
    MaxShield = 1,
    Defense = 0,
    OrbSpawnTime = 6,
    OrbLifeTime = 15,

    --- States
    InCombat = false,
    OrbAttackingTime = false,

    --- Buffes
    HealthBuff = 0,
    JumpBuff = 0,
    MinDMGBuff = 0,
    MaxDMGBuff = 0,
    MagicBuff = 0,
    ShieldBuff = 0,
    SpeedBuff = 0,
    RestoreBuff = 10,
    HealBuff = 10,
    TPRestoreBuff = 10,

    BurnChance = 0,
    DodgeChance = 0,
    CriChance = 1,
    CriDMG = 100,

    --- Class stats
    Combo = 0,
    Stack = 0,
    Focus = 0,
    Guard = 0,
    RogueCri = 0
}
