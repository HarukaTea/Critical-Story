--!strict
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Net = Warp.Client

local Events = {
	AddPoints = Net("AddSkillPoints"),
	CombatStart = Net("CombatStart"),
	CreateHint = Net("CreateHint"),
	ClientTween = Net("ClientTween"),
	ChangePlayerSetting = Net("ChangePlayerSetting"),
	ChestUnlocked = Net("ChestUnlocked"),
	ChangeMobTarget = Net("ChangeMobTarget"),
	CharTakeDMG = Net("CharTakeDMG"),
	ChangePlayerLocation = Net("ChangePlayerLocation"),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	ForceReset = Net("ForceReset"),
	GiveDrop = Net("GiveDrop"),
	ItemCD = Net("ItemCD"),
	LevelUp = Net("LevelUpVFX"),
	MagicCasted = Net("MagicCasted"),
	MobTakeDMG = Net("MobTakeDMG"),
	NPCChat = Net("NPCChat"),
	NPCChatEnded = Net("NPCChatEnded"),
	NewQuest = Net("NewQuest"),
	PlaySound = Net("PlaySound"),
	PlayAnimation = Net("PlayAnimation"),
	PartyInvite = Net("PartyInvite"),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinCombat = Net("RejoinCombat"),
	RejoinRequest = Net("RejoinRequest"),
	SwitchScene = Net("SwitchScene"),
	UseItem = Net("UseItem"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
