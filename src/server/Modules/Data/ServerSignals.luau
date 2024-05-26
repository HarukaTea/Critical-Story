--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

local Signals = {
	BanRequest = Signal(),
	LevelUp = Signal(),
	QuestComplete = Signal(),

	--- story
	StoryMain1 = Signal(),
	FirstStepTutorial = Signal(),
	CompletedInitusBay = Signal(),

	FChenPTown2 = Signal()
}

return Signals
