--!strict

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local Signals = {
	CreateHint = Signal(),
	NPCChat = Signal(),
	PlayAnimation = Signal(),
	SwitchScene = Signal()
}

return Signals
