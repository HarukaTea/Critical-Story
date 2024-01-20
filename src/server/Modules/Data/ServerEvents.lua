--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local FastNet2 = require(RepS.Modules.Packages.imezx_fastnet2.fastnet2)

local Net = FastNet2.new

local Events = {
	AddPoints = Net("AddSkillPoints"),
	CombatStart = Net("CombatStart"),
	CreateHint = Net("CreateHint", false),
	ClientTween = Net("ClientTween", false),
	CastClassSkill = Net("CastClassSkill"),
	ChestUnlocked = Net("ChestUnlocked", false),
	EquipItems = Net("EquipItems"),
	ErrorDataStore = Net("ErrorDataStore"),
	GiveDrop = Net("GiveDrop"),
	ItemCD = Net("ItemCD", false),
	LevelUp = Net("LevelUpVFX", false),
	MagicCasted = Net("MagicCasted", false),
	PlaySound = Net("PlaySound", false),
	PlayAnimation = Net("PlayAnimation", false),
	RefreshBackpack = Net("RefreshBackpack"),
	RejoinRequest = Net("RejoinRequest", false),
	UseItem = Net("UseItem"),
	UpdatePinnedItems = Net("UpdatePinnedItems"),
}

return Events
