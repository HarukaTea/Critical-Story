--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

local Signals = {
	LevelUp = Signal(),
	QuestComplete = Signal(),
	RejoinPlace = Signal(),

	--- story
	StoryMain1 = Signal(),
	FirstStepTutorial = Signal(),
	CompletedInitusBay = Signal(),

	JoinFaction = Signal(),

	FChenPTown2 = Signal()
}

return Signals
