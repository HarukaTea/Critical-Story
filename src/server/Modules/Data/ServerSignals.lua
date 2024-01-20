--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages["red-blox_signal"].signal)

local Signals = {
	CombatEnd = Signal(),
	ItemsAdded = Signal(),
	ItemsEquipped = Signal(),
	ItemsPinned = Signal(),
	LevelUp = Signal(),
}

return Signals
