--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

return {
	CreateHint = Signal(),
	CreateFullScreenHint = Signal(),
	CameraScene = Signal(),
	ExCategoryOpened = Signal(),
	EnableMapDetails = Signal(),
	ContinueNPCChat = Signal(),
	PlaySound = Signal(),
	PlayAnimation = Signal(),
	PlayerChatted = Signal(),
	EnterNPCChat = Signal(),

	--- story
	StoryMain1 = Signal()
}
