--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Net = Warp.Client

local Events = {
	AddPoints = Net("AddSkillPoints"),
	CombatStart = Net("CombatStart"),
	CreateHint = Net("CreateHint", false),
	ClientTween = Net("ClientTween", false),
	CastClassSkill = Net("CastClassSkill"),
	ChangeInviteAccess = Net("ChangeInviteAccess", false),
	ChestUnlocked = Net("ChestUnlocked", false),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	GiveDrop = Net("GiveDrop"),
	ItemCD = Net("ItemCD", false),
	LevelUp = Net("LevelUpVFX", false),
	MagicCasted = Net("MagicCasted", false),
	PlaySound = Net("PlaySound", false),
	PlayAnimation = Net("PlayAnimation", false),
	PartyInvite = Net("PartyInvite"),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinCombat = Net("RejoinCombat"),
	RejoinRequest = Net("RejoinRequest", false),
	UseItem = Net("UseItem"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
