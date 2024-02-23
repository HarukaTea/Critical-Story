--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local NewSignal = Signal.new

local Signals = {
	CreateHint = NewSignal(),
	ClientTween = NewSignal(),
	NPCChat = NewSignal(),
	PlayAnimation = NewSignal(),
	SwitchScene = NewSignal()
}

return Signals
