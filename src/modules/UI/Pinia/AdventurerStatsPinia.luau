--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Formula = require(RepS.Modules.Data.Formulas)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local fromScale = UDim2.fromScale
local wait = task.wait

local function AdventurerStatsPinia(self: table)
    local plr = self.plr :: Player
    local char = self.char :: Model

	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.inventory = plr:WaitForChild("Inventory", 999)
	self.charData = char:WaitForChild("CharStats", 999)
	self.humanoid = char.Humanoid

	self.playerData = {
		EXP = {
			Value(plr:GetAttribute("EXP")),
			Value(Formula.EXP(plr:GetAttribute("Levels"))),
		},
		Class = Value(plr:GetAttribute("Class")),
		Levels = Value(plr:GetAttribute("Levels")),
		Gold = Value(HarukaLib:NumberConvert(plr:GetAttribute("Gold"), "%.1f")),
		RP = Value(HarukaLib:NumberConvert(plr:GetAttribute("RP"), "%.1f")),
		LvPoints = Value(plr:GetAttribute("LvPoints"))
	}

	self.charStatsDict = {
		HP = { Value(char.Humanoid.Health), Value(char.Humanoid.MaxHealth) },
		MP = { Value(char:GetAttribute("Mana")), Value(char:GetAttribute("MaxMana")) },
		DEF = { Value(char:GetAttribute("Shield")), Value(char:GetAttribute("MaxShield")) },

		HPHealing = Value(false), DEFRepairing = Value(false),

		MonsterAmount = Value({}),
		IsInCombat = Value(false),
		EffectsList = Value({}),
	}

    self.charDMGStats = {
        MinDMG = Value(char:GetAttribute("MinDMG")),
        MaxDMG = Value(char:GetAttribute("MaxDMG")),
        Magic = Value(char:GetAttribute("Magic")),

		MinDMGBuff = Value(char:GetAttribute("MinDMGBuff")),
		MaxDMGBuff = Value(char:GetAttribute("MaxDMGBuff")),
		MagicBuff = Value(char:GetAttribute("MagicBuff")),
    }

	self.charClassInfo = {
		Warrior = Value(0),
		Archer = Value(0),
		Wizard = Value(0),
		Knight = Value(0),
		Rogue = Value(0),
		Alchemist = Value({}),
		Juggernaut = Value(0),
		Reaper = Value(0)
	}

	self.nowMobIndex = 1

    self.newAddedItems = Value({})

    self.levelUpShown, self.levelUpTitleShown, self.levelUpPos =
        Value(false), Value(false), Value(fromScale(0.55, 0))

	self.locationScope = Fusion.scoped({})
    self.locationInfo = {
		Name = Value(""),
		Desc = Value(""),
		Shown = Value(false),
		OverallTrans = Value(1),
		OverallStrokeTrans = Value(1),
		HorizonLineSize = Value(fromScale(0.25, 0.07)),
        HorizonLineTweenInfo = Value(AssetBook.TweenInfos.two),
		RLevelTrans = Value(1),
		RLevelStrokeTrans = Value(1),
		RLevelText = Value("")
	}

    self.promptsList = Value({})
	self.currentPromptIndex = Value(1)

    self.quests = Value(self.plr:WaitForChild("Quests", 999):GetChildren())

	self.passiveEquipList = { Value("Null"), Value("Null"), Value("Null") }
	self.passiveSlotList = { Value(), Value(), Value() }

	self.activeInnerCDList = { false, false, false }
	self.activeEquipList = { Value("Null"), Value("Null"), Value("Null") }
	self.activeCDList = { Value(0), Value(0), Value(0) }
	self.activeCDRotationList = { Value(0), Value(0), Value(0) }
	self.activeSlotList = { Value(), Value(), Value() }

	self.targetingMobs = Value({})
	self.monsterTargetingPos = Value(fromScale(-0.2, 0.5))
	self.targetingMob = Value(self.charData.TargetMonster.Value)

	function self:UseItem(slot: number)
		local activeInnerCDList = self.activeInnerCDList
		if activeInnerCDList[slot] then return end

		activeInnerCDList[slot] = true
		Events.UseItem.Fire({ ItemId = Fusion.peek(self.activeEquipList[slot]) })

		wait(1)
		activeInnerCDList[slot] = false
	end
end

return AdventurerStatsPinia
