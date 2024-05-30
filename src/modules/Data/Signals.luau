--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

return {
	CreateHint = Signal(),
	ExCategoryOpened = Signal(),
	EnableMapDetails = Signal(),
	NPCChat = Signal(),
	PlayAnimation = Signal(),
	PlayerChatted = Signal(),
	StartNPCChat = Signal(),


	--- story
	StoryMain1 = Signal()
}
