--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Net = Warp.Server

local Events = {
	AddPoints = Net("AddSkillPoints"),
	CombatStart = Net("CombatStart"),
	CreateHint = Net("CreateHint"),
	ClientTween = Net("ClientTween"),
	ChangeInviteAccess = Net("ChangeInviteAccess"),
	ChestUnlocked = Net("ChestUnlocked"),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	ForceReset = Net("ForceReset"),
	GiveDrop = Net("GiveDrop"),
	ItemCD = Net("ItemCD"),
	LevelUp = Net("LevelUpVFX"),
	MagicCasted = Net("MagicCasted"),
	NPCChat = Net("NPCChat"),
	NPCChatEnded = Net("NPCChatEnded"),
	PlaySound = Net("PlaySound"),
	PlayAnimation = Net("PlayAnimation"),
	PartyInvite = Net("PartyInvite"),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinCombat = Net("RejoinCombat"),
	RejoinRequest = Net("RejoinRequest"),
	UseItem = Net("UseItem"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
