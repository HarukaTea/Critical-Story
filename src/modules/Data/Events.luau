--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

return {
	AddPoints = Warp("AddSkillPoints"),
	BuyItems = Warp("BuyItems"),
	CombatStart = Warp("CombatStart"),
	CreateHint = Warp("CreateHint"),
	ClientTween = Warp("ClientTween"),
	ChangePlayerSetting = Warp("ChangePlayerSetting"),
	ChestUnlocked = Warp("ChestUnlocked"),
	ChangeMobTarget = Warp("ChangeMobTarget"),
	CharTakeDMG = Warp("CharTakeDMG"),
	ChangePlayerLocation = Warp("ChangePlayerLocation"),
	EquipItems = Warp("EquipItems"),
	EnterShopping = Warp("EnterShopping"),
	ItemCD = Warp("ItemCD"),
	ForceReset = Warp("ForceReset"),
	LockCam = Warp("LockCam"),
	GiveDrop = Warp("GiveDrop"),
	LevelUp = Warp("LevelUpVFX"),
	MobTakeDMG = Warp("MobTakeDMG"),
	NPCChat = Warp("NPCChat"),
	NPCChatEnded = Warp("NPCChatEnded"),
	NewQuest = Warp("NewQuest"),
	PlaySound = Warp("PlaySound"),
	PlayAnimation = Warp("PlayAnimation"),
	RejoinRequest = Warp("RejoinRequest"),
	StoryEvents = Warp("StoryEvents"),
	UseItem = Warp("UseItem"),
	UpdatePinnedItems = Warp("UpdatePinnedItems"),
}
