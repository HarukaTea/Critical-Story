--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Fusion = require(RepS.Modules.Packages.Fusion)

local fromScale = UDim2.fromScale

local function TurnBaseUIPinia(self: table)
    self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.emptyList = {}

    self.playerClass = Value(self.plr:GetAttribute("Class"))

    self.charStatsDict = {
        isInCombat = Value(false),
        TP = Value(0)
    }

    self.phaseBarProgress = Value(fromScale(0, 1))
    self.phaseBarTweenInfo = Value(AssetBook.TweenInfos.fourHalf)

    self.bottomTipText = Value("")

    self.panelPos = Value(fromScale(0.5, 5))
    self.actionClickCD = false

    self.inventory = self.plr:WaitForChild("Inventory", 999)

    self.sidePanelAbsContentSize, self.sidePanelAbsSize = { Value(0), Value(0) }, { Value(0), Value(0) }
    self.items = Value({})
    self.itemPanelVisible = Value(false)
    self.skills = Value({})
    self.skillPanelVisible = Value(false)

    self.targetingMobs = Value({})
    self.monsterTargetingPos = Value(fromScale(-0.2, 0.5))
    self.targetingMob = Value(self.charData.TargetMonster.Value)

    self.playersInCombat = Value({})
    self.targetingPlayer = Value(Players.LocalPlayer)
    self.playerTargetingPos = Value(fromScale(1.05, 0.5))

    self.currentPhase = Value("Player")
	self.phasePos = { Value(fromScale(-0.2, 0)), Value(fromScale(1.2, 0.9)) }
	self.phaseTrans = Value(1)

    self.isInAttackPhase = Value(false)
    self.criBarPos = Value(fromScale(0.6, 0))
end

return TurnBaseUIPinia
