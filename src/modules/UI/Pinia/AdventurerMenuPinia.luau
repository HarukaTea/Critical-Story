--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ClassBook = require(RepS.Modules.Data.ClassBook)
local Fusion = require(RepS.Modules.Packages.Fusion)

local function AdventurerMenuPinia(self: table) : table
	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.chosenFilter = Value("Character")
	self.frames = {
		Character = Value(true),
		Settings = Value(false),
		Guild = Value(false),
		Quests = Value(false),
		Donation = Value(false)
	}
	self.panelFilters = {
		Character = Value("Attributes"),
		Settings = Value("Graphics")
	}
	self.panelFilterFrames = {
		Character = {
			Attributes = Value(true),
			Points = Value(false),
			Classes = Value(false),
			Talents = Value(false)
		},
		Settings = {
			Graphics = Value(true),
			Combat = Value(false),
			Sounds = Value(false),
			Misc = Value(false)
		}
	}

	self.classInfoAbsSize = Value(Vector2.new())
	self.classInfoDesc = Value("")

	self.classTalents = Value({})
	self.currentTalent = Value({})
	self.currentMaterialsNeeded = Value({})
	self.talentAbsSize = Value(Vector2.new())

	self.pointsPerAdd = Value("1")

	self.packListAbsSize, self.packListAbsContentSize = Value(Vector2.new()), Value(Vector2.new())
	self.donationListAbsSize, self.donationListAbsContentSize = Value(Vector2.new()), Value(Vector2.new())
	self.donationList = Value({})

	self.questListAbsSize, self.questListAbsContentSize = Value(Vector2.new()), Value(Vector2.new())
	self.questList = Value({})
	self.questDescAbsSize = Value(Vector2.new())
	self.questDesc, self.questRewardsList = Value(""), Value({})
	self.questRewardsListAbsSize, self.questRewardsListAbsContentSize = Value(Vector2.new()), Value(Vector2.new())

    self.playerData = {
		Class = Value("Warrior"),
		Levels = Value(1),
		LvPoints = Value(0),
		DMG = Value(0),
		Magic = Value(0),
		Health = Value(0),
		Mana = Value(0),
		Shield = Value(0),
		Gold = Value(0),
		EXP = {
			Value(0),
			Value(0)
		},

		ClassUnlocks = {
			Warrior = Value(true)
		}
	}
	for class: string, _ in ClassBook.ClassInfo do
		self.playerData.ClassUnlocks[class] = Value(false)
	end

	self.charData = {
		MinDMG = Value(0),
		MaxDMG = Value(0),
		Magic = Value(0),
		Mana = Value(0),
		Shield = Value(0),
		Health = Value(0),
		CriChance = Value(0),
		CriDMG = Value(0),
	}

    self.playerSettings = {
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true),
		MapDetails = Value(true),
		MapShadows = Value(true),
		TreeOptimizations = Value(true),
		HideRole = Value(false)
	}
end

return AdventurerMenuPinia
