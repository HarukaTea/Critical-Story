--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local function AdventurerMenuPinia(self: table) : table
    local plr = self.plr :: Player
    local char = self.char :: Model

	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

	self.Add, self.Empty = HarukaLib.Bin()

    self.chosenFilter = Value("Character")
	self.frames = { Character = Value(true), Settings = Value(false) }

    self.playerData = {
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		DMG = Value(plr:GetAttribute("DMGPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Mana = Value(plr:GetAttribute("ManaPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
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
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true),
		MapDetails = Value(true)
	}
end

return AdventurerMenuPinia
