--!strict

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local Signals = {
	LevelUp = Signal(),
	QuestComplete = Signal(),

	--- story
	FirstStepTutorial = Signal(),
	CompletedInitusBay = Signal(),

	FChenPTown2 = Signal()
}

return Signals
