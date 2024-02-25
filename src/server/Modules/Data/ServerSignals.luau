--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local NewSignal = Signal.new

local Signals = {
	CombatEnd = NewSignal(),
	ItemsAdded = NewSignal(),
	ItemsEquipped = NewSignal(),
	ItemsPinned = NewSignal(),
	LevelUp = NewSignal(),
	QuestComplete = NewSignal(),

	--- story
	FirstStepTutorial = NewSignal(),

	FChenPTown2 = NewSignal()
}

return Signals
