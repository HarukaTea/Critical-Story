--!nocheck

local Formulas = {}

Formulas.EXP = function(level: number) : number
    return math.floor(777 * math.log10(level) + 300)
end

Formulas.Gold = function(level: number) : number
    return math.ceil(5.1599 * level)
end

Formulas.RP = function(level: number) : number
    return math.ceil(1.599 * level)
end

return Formulas
