--!nocheck

local Formulas = {}

Formulas.EXP = function(level: number) : number
    --// V0.9: return math.floor(777 * math.log10(level) + 300)
    return math.floor(level ^ 1.65) + 59
end

Formulas.Gold = function(level: number) : number
    ---//V0.9: return math.ceil(5.1599 * level)
    return math.ceil(Formulas.EXP(level) / 1.5)
end

Formulas.RP = function(level: number) : number
    --//V0.9: return math.ceil(1.599 * level)
    return math.ceil(Formulas.EXP(level) / 5)
end

Formulas.MonsterHP = function(level: number) : number
    return math.floor(level ^ 2.2599) + 39
end

Formulas.MonsterDMG = function(level: number) : number
    return math.floor(level ^ 1.3599) + 4
end

Formulas.PlayerDMGMin = function(point: number)
    return 5 + point
end
Formulas.PlayerDMGMax = function(point: number)
    return 10 + point * 2
end

Formulas.PlayerMagic = function(point: number)
    return 7 + point * 2
end

Formulas.PlayerHP = function(point: number)
    return 100 + point * 50
end

Formulas.PlayerShield = function(point: number)
    return point * 20
end

Formulas.PlayerMana = function(point: number)
    return 100 + point * 20
end

Formulas.PointsResetCost = 20
Formulas.LevelCap = 1100
Formulas.LevelPerPoint = 2
Formulas.GlobalEXPMultiplier = 21

return Formulas
