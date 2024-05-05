--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local Value = Fusion.Value

local fromScale = UDim2.fromScale

local function PlayerListPinia(self: table)
    self.list = Value()

	self.absSize, self.absContentSize = Value(90), Value(30)
	self.players = Value({})
	self.isOpen = Value(true)

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
