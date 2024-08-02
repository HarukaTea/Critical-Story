--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local function HintsPinia(self: table)
    self.scope = Fusion.scoped({})

    local function Value(val: any) : any
        return Fusion.Value(self.scope, val)
    end

    self.hintsList = Value({})

    self.fullScreenText = Value("")
    self.fullScreenTrans = Value(1)
end

return HintsPinia
