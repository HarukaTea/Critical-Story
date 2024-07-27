--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local fromScale = UDim2.fromScale

local function PlayerListPinia(self: table)
    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.list = Value()

	self.absSize, self.absContentSize = Value(Vector2.new()), Value(Vector2.new())
	self.players = Value({})
	self.isOpen = Value(true)

    self.isInCombat = Value(false)

    self.playerDescVisible = Value(false)
    self.playerDescBGSize = Value(fromScale(1, 0.86))

    self.classImage = Value("")
    self.displayName = Value("")
    self.userName = Value("")
    self.level = Value("")
    self.role = Value("")

    self.playerItemIconList = {
        Value("Null"), Value("Null"), Value("Null"),
        Value("Null"), Value("Null"), Value("Null"), Value("Null")
    }
end

return PlayerListPinia
