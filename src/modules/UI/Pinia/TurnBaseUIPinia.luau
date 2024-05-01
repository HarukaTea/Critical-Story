--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Value = Fusion.Value

local fromScale = UDim2.fromScale

local function TurnBaseUIPinia(self: table)
    local char = self.char :: Model

    self.isInCombat = Value(char:GetAttribute("InCombat"))

    self.charStatsDict = {
		Shield = Value(char:GetAttribute("Shield")),
		MaxShield = Value(char:GetAttribute("MaxShield")),
		TP = Value(char:GetAttribute("TP"))
	}

    self.phaseBarProgress = Value(fromScale(0, 1))
    self.phaseBarTweenInfo = Value(AssetBook.TweenInfos.fourHalf)

    self.panelPos = Value(fromScale(0.5, 5))
    self.actionClickCD = false
    self.transHPBarSize = Value(fromScale(0, 0.875))

    self.inventory = self.plr:WaitForChild("Inventory", 999)
    self.itemPanelAbsContentSize, self.itemPanelAbsSize = Value(0), Value(0)
    self.items = Value({})
    self.itemPanelVisible = Value(false)

    self.skillPanelAbsContentSize, self.skillPanelAbsSize = Value(0), Value(0)
    self.skills = Value({})
    self.skillPanelVisible = Value(false)

    self.targetingMobs = Value({})
    self.monsterHPPos, self.monsterTargetingPos = Value(fromScale(0.3, -0.5)), Value(fromScale(-0.2, 0.5))

    self.playersInCombat = Value({})
    self.playersListPos = Value(fromScale(-0.015, -0.5))
    self.targetingMob = Value(self.charData.TargetMonster.Value)

    self.currentPhase = Value("Player")
	self.phasePos = { Value(fromScale(-0.2, 0)), Value(fromScale(1.2, 0.9)) }
	self.phaseTrans = Value(1)
end

return TurnBaseUIPinia
