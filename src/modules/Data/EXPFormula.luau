--!nocheck

local EXPFormula = function(level: number) : number
    return math.floor(777 * math.log10(level) + 300)
end

return EXPFormula
