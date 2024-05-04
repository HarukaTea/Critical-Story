--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Events = {
	AddPoints = Warp("AddSkillPoints"),
	CombatStart = Warp("CombatStart"),
	CreateHint = Warp("CreateHint"),
	ClientTween = Warp("ClientTween"),
	ChangePlayerSetting = Warp("ChangePlayerSetting"),
	ChestUnlocked = Warp("ChestUnlocked"),
	ChangeMobTarget = Warp("ChangeMobTarget"),
	CharTakeDMG = Warp("CharTakeDMG"),
	ChangePlayerLocation = Warp("ChangePlayerLocation"),
	CreateCombatBorder = Warp("CreateCombatBorder"),
	CameraPointTo = Warp("CameraPointTo"),
	ClassClientVFX = Warp("ClassClientVFX"),
	NewPhase = Warp("NewPhase"),
	NextActionRequest = Warp("NextActionRequest"),
	EquipItems = Warp("EquipItems"),
	ErrorDataStore = Warp("ErrorDataStore"),
	ForceReset = Warp("ForceReset"),
	FreezePlayerControls = Warp("FreezePlayerControls"),
	GiveDrop = Warp("GiveDrop"),
	LevelUp = Warp("LevelUpVFX"),
	MobTakeDMG = Warp("MobTakeDMG"),
	NPCChat = Warp("NPCChat"),
	NPCChatEnded = Warp("NPCChatEnded"),
	NewQuest = Warp("NewQuest"),
	PlaySound = Warp("PlaySound"),
	PlayAnimation = Warp("PlayAnimation"),
	RefreshBackpack = Warp("RefreshBackpack"),
	RejoinRequest = Warp("RejoinRequest"),
	SwitchScene = Warp("SwitchScene"),
	UseItem = Warp("UseItem"),
	UpdatePinnedItems = Warp("UpdatePinnedItems"),
}

return Events
