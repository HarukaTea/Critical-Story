--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Bin = require(RepS.Modules.Packages.Bin)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Value = Fusion.Value

local floor = math.floor
local fromScale = UDim2.fromScale

local function AdventurerStatsPinia(self: table)
    local plr = self.plr :: Player
    local char = self.char :: Model

	self.UI, self.skillInfo, self.classFrame = Value(), Value(), Value()

    self.inventory = plr:WaitForChild("Inventory", 999)
	self.charData = char:WaitForChild("CharStats", 999)
	self.humanoid = char.Humanoid

	self.playerData = {
		EXP = {
			Value(plr:GetAttribute("EXP")),
			Value(floor(plr:GetAttribute("Levels") ^ 1.85) + 60),
		},
		Class = Value(plr:GetAttribute("Class")),
		Levels = Value(plr:GetAttribute("Levels")),
		Gold = Value(HarukaLib:NumberConvert(plr:GetAttribute("Gold"), "%.1f")),
		RP = Value(HarukaLib:NumberConvert(plr:GetAttribute("RP"), "%.1f")),
		LvPoints = Value(plr:GetAttribute("LvPoints"))
	}

	self.charStatsDict = {
		HP = { Value(char.Humanoid.Health), Value(char.Humanoid.MaxHealth) },

		MonsterAmount = Value({}),
		IsInCombat = Value(false),
		EffectsList = Value({}),
	}

    self.charDMGStats = {
        MinDMG = Value(char:GetAttribute("MinDMG")),
        MaxDMG = Value(char:GetAttribute("MaxDMG")),
        Magic = Value(char:GetAttribute("Magic")),
    }

	self.Add, self.Empty = Bin()

	self.charClassInfo = {
		Warrior = Value(0),
		Archer = Value(0),
		Wizard = Value(0),
		Knight = Value(0),
		Rogue = Value(0)
	}

    self.version, self.privateId, self.serverLocation =
		Value(RepS.Package.Version.Value),
        Value(RepS.Package.PrivateServerId.Value),
        Value(RepS.Package.ServerLocation.Value)

    self.passiveIconList = { Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null"), Value("Null") }

    self.chatDialogueAbsSize = Value(24)
    self.chatText = Value("")
    self.chatSpeaker = Value("")
    self.chatChoices = Value({})
    self.triangleVisible = Value(true)
    self.isChatting = Value(false)

    self.newAddedItems = Value({})

    self.levelUpShown, self.levelUpTitleShown, self.levelUpPos =
        Value(false), Value(false), Value(fromScale(0.55, 0))

    self.locationInfo = {
		Thread = nil,
		Name = Value(""),
		Desc = Value(""),
		Shown = Value(false),
		OverallTrans = Value(1),
		OverallStrokeTrans = Value(1),
		HorizonLineSize = Value(fromScale(0.25, 0.07)),
        HorizonLineTweenInfo = Value(AssetBook.TweenInfos.two)
	}

    self.promptsList = Fusion.Value({})

    self.quests = Fusion.Value(self.plr:WaitForChild("Quests", 999):GetChildren())
end

return AdventurerStatsPinia
