--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local function AdventurerMenuPinia(self: table) : table
    local plr = self.plr :: Player
    local char = self.char :: Model

	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.chosenFilter = Value("Character")
	self.frames = { Character = Value(true), Settings = Value(false) }

	self.pointsPerAdd = Value("1")

	self.errorAbsContentSize, self.errorAbsSize = Value(0), Value(0)

    self.playerData = {
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		DMG = Value(plr:GetAttribute("DMGPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Mana = Value(plr:GetAttribute("ManaPoints")),
		Gold = Value(plr:GetAttribute("Gold"))
	}

	self.charData = {
		MinDMG = Value(char:GetAttribute("MinDMG")),
		MaxDMG = Value(char:GetAttribute("MaxDMG")),
		Magic = Value(char:GetAttribute("Magic")),
		Mana = Value(char:GetAttribute("MaxMana")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth)
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
