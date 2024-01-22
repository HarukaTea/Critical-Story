--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local NewSignal = Signal.new

local Signals = {
	CreateHint = NewSignal(),
	PlayAnimation = NewSignal()
}

return Signals
