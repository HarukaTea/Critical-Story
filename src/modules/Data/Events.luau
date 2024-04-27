--!nocheck
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
	CreateCombatBorder = Net("CreateCombatBorder"),
	CameraPointTo = Net("CameraPointTo"),
	ClassClientVFX = Net("ClassClientVFX"),
	NewPhase = Net("NewPhase"),
	NextActionRequest = Net("NextActionRequest"),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	ForceReset = Net("ForceReset"),
	FreezePlayerControls = Net("FreezePlayerControls"),
	GiveDrop = Net("GiveDrop"),
	LevelUp = Net("LevelUpVFX"),
	MobTakeDMG = Net("MobTakeDMG"),
	NPCChat = Net("NPCChat"),
	NPCChatEnded = Net("NPCChatEnded"),
	NewQuest = Net("NewQuest"),
	PlaySound = Net("PlaySound"),
	PlayAnimation = Net("PlayAnimation"),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinRequest = Net("RejoinRequest"),
	SwitchScene = Net("SwitchScene"),
	UseItem = Net("UseItem"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
