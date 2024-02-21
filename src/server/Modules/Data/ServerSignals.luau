--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Signal = Warp.Signal

local Signals = {
	CombatEnd = Signal("CombatEnd"),
	ItemsAdded = Signal("ItemsAdded"),
	ItemsEquipped = Signal("ItemsEquipped"),
	ItemsPinned = Signal("ItemsPinned"),
	LevelUp = Signal("LevelUp"),

	--- story
	FirstStepTutorial = Signal("FirstStepStory")
}

return Signals
