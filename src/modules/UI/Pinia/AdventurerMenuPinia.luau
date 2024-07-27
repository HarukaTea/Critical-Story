--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Formula = require(RepS.Modules.Data.Formulas)

local function AdventurerMenuPinia(self: table) : table
    local plr = self.plr :: Player
    local char = self.char :: Model

	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.chosenFilter = Value("Character")
	self.frames = {
		Character = Value(true),
		Settings = Value(false),
		Guild = Value(false),
		Packs = Value(false),
		Donation = Value(false)
	}
	self.panelFilters = {
		Character = Value("Attributes")
	}
	self.panelFilterFrames = {
		Character = {
			Attributes = Value(true),
			Points = Value(false),
			Classes = Value(false),
			Talents = Value(false)
		}
	}

	self.classInfoAbsSize = Value(Vector2.new())
	self.classInfoDesc = Value("")

    self.playerData = {
		Class = Value(plr:GetAttribute("Class")),
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		DMG = Value(plr:GetAttribute("DMGPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Mana = Value(plr:GetAttribute("ManaPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
		Gold = Value(plr:GetAttribute("Gold")),
		EXP = {
			Value(plr:GetAttribute("EXP")),
			Value(Formula.EXP(plr:GetAttribute("Levels")))
		},

		ClassUnlocks = {
			Warrior = Value(true)
		}
	}
	for class: string, _ in AssetBook.ClassInfo do
		self.playerData.ClassUnlocks[class] = Value(plr:GetAttribute("CLASS_UNLOCK_"..class))
	end

	self.charData = {
		MinDMG = Value(char:GetAttribute("MinDMG")),
		MaxDMG = Value(char:GetAttribute("MaxDMG")),
		Magic = Value(char:GetAttribute("Magic")),
		Mana = Value(char:GetAttribute("MaxMana")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth),
		CriChance = Value(char:GetAttribute("CriChance")),
		CriDMG = Value(char:GetAttribute("CriDMG")),
	}

    self.playerSettings = {
		Musics = Value(plr:GetAttribute("Musics")),
		SFXs = Value(plr:GetAttribute("SFXs")),
		PublicCombat = Value(plr:GetAttribute("CombatMode") == "Public"),
		PotatoMode = Value(plr:GetAttribute("PotatoMode")),
		PlayerList = Value(plr:GetAttribute("PlayerList")),
		MapDetails = Value(plr:GetAttribute("MapDetails")),
		Particles = Value(plr:GetAttribute("Particles"))
	}
end

return AdventurerMenuPinia
