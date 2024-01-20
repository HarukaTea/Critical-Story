--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages["red-blox_signal"].signal)

local Signals = {
	CreateHint = Signal(),
	PlayAnimation = Signal()
}

return Signals
