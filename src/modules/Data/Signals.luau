--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local Signals = {
	CreateHint = Signal(),
	CameraPointTo = Signal(),
	ExCategoryOpened = Signal(),
	NPCChat = Signal(),
	PlayAnimation = Signal(),
	SwitchScene = Signal()
}

return Signals
