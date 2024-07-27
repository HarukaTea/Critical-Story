--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

return {
	CreateHint = Signal(),
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
