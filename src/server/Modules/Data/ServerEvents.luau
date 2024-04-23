--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Net = Warp.Server

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
	CastSkillRequest = Net("CastSkillRequest"),
	NewPhase = Net("NewPhase"),
	NextActionRequest = Net("NextActionRequest"),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	ForceReset = Net("ForceReset"),
	FreezePlayerControls = Net("FreezePlayerControls"),
	GiveDrop = Net("GiveDrop"),
	LevelUp = Net("LevelUpVFX"),
	MagicCasted = Net("MagicCasted"),
	MobTakeDMG = Net("MobTakeDMG"),
	NPCChat = Net("NPCChat"),
	NPCChatEnded = Net("NPCChatEnded"),
	NewQuest = Net("NewQuest"),
	PlaySound = Net("PlaySound"),
	PlayAnimation = Net("PlayAnimation"),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinRequest = Net("RejoinRequest"),
	SwitchScene = Net("SwitchScene"),
	UseItemRequest = Net("UseItemRequest"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
