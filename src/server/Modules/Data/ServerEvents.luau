--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

return {
	AddPoints = Warp(true, "AddSkillPoints"),
	CombatStart = Warp(true, "CombatStart"),
	CreateHint = Warp(false, "CreateHint"),
	ClientTween = Warp(true, "ClientTween"),
	ChangePlayerSetting = Warp(false, "ChangePlayerSetting"),
	ChestUnlocked = Warp(false, "ChestUnlocked"),
	ChangeMobTarget = Warp(false, "ChangeMobTarget"),
	CharTakeDMG = Warp(true, "CharTakeDMG"),
	ChangePlayerLocation = Warp(false, "ChangePlayerLocation"),
	EquipItems = Warp(true, "EquipItems"),
	ItemCD = Warp(true, "ItemCD"),
	ForceReset = Warp(false, "ForceReset"),
	LockCam = Warp(true, "LockCam"),
	GiveDrop = Warp(true, "GiveDrop"),
	LevelUp = Warp(false, "LevelUpVFX"),
	MobTakeDMG = Warp(true, "MobTakeDMG"),
	NPCChat = Warp(true, "NPCChat"),
	NPCChatEnded = Warp(true, "NPCChatEnded"),
	NewQuest = Warp(true, "NewQuest"),
	PlaySound = Warp(false, "PlaySound"),
	PlayAnimation = Warp(false, "PlayAnimation"),
	RejoinRequest = Warp(false, "RejoinRequest"),
	StoryEvents = Warp(true, "StoryEvents"),
	UseItem = Warp(true, "UseItem"),
	UpdatePinnedItems = Warp(false, "UpdatePinnedItems"),
}
