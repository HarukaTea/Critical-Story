--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local Value = Fusion.Value

local function AdventurerMenuPinia(self: table) : table
    local plr = self.plr :: Player
    local char = self.char :: Model

    self.UI = Value()

    self.chosenFilter = Value("Character")

    self.playerData = {
		Levels = Value(plr:GetAttribute("Levels")),
		LvPoints = Value(plr:GetAttribute("LvPoints")),
		DMG = Value(plr:GetAttribute("DMGPoints")),
		Magic = Value(plr:GetAttribute("MagicPoints")),
		Health = Value(plr:GetAttribute("HealthPoints")),
		Shield = Value(plr:GetAttribute("ShieldPoints")),
		Gold = Value(plr:GetAttribute("Gold"))
	}

	self.charData = {
		MinDMG = Value(char:GetAttribute("MinDMG")),
		MaxDMG = Value(char:GetAttribute("MaxDMG")),
		Magic = Value(char:GetAttribute("Magic")),
		Shield = Value(char:GetAttribute("MaxShield")),
		Health = Value(char.Humanoid.MaxHealth)
	}

    self.playerSettings = {
		Musics = Value(true),
		SFXs = Value(true),
		PublicCombat = Value(false),
		PotatoMode = Value(false),
		PlayerList = Value(true),
	}
end

return AdventurerMenuPinia
