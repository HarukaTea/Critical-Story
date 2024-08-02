--!nocheck

return {
    --- Stats
    MinDMG = 0,
    MaxDMG = 0,
    Magic = 0,
    Mana = 100,
    MaxMana = 100,
    Shield = 0,
    MaxShield = 0,
    Defense = 0,

    --- States
    InCombat = false,
    OrbSpawnTime = 3,
    OrbLifeTime = 12,
    CurrentState = "None",
    ShieldRepairing = false,
    HPRecovering = false,

    --- Buffes
    HealthBuff = 0,
    JumpBuff = 0,
    MinDMGBuff = 0,
    MaxDMGBuff = 0,
    MagicBuff = 0,
    ManaBuff = 0,
    ShieldBuff = 0,
    SpeedBuff = 0,
    RestoreBuff = 10,
    HealBuff = 10,

    BurnChance = 0,
    PoisonChance = 0,
    DodgeChance = 0,
    CriChance = 1,
    CriDMG = 100,

    --- Class stats
    Combo = 0,
    Stack = 0,
    Focus = 0,
    Guard = 0,
    RogueCri = 0,
    Rage = 0,
    LifeStolen = 0
}
