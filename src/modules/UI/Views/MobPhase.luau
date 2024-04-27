--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local MobPhaseMobBar = require(RepS.Modules.UI.Components.MobPhaseMobBar)

local Children, Value, peek = Fusion.Children, Fusion.Value, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait, cancel, spawn = task.wait, task.cancel, task.spawn
local insert, remove, tFind = table.insert, table.remove, table.find

local function MobPhase(self: table) : Frame
    self.targetingMobs = Value({})
    self.monsterHPPos, self.monsterTargetingPos = Value(fromScale(0.3, -0.5)), Value(fromScale(-0.2, 0.5))

    local function _addMonster(monster: ObjectValue)
		wait()
		local nowMonsters = peek(self.targetingMobs)

		insert(nowMonsters, monster)
		self.targetingMobs:set(nowMonsters)
	end
	local function _removeMonster(monster: ObjectValue)
		local monsters = peek(self.targetingMobs)
		if monster == monsters[self.nowMobIndex] then self.nowMobIndex = 1 end

		wait(1)
		local afterMonsters = peek(self.targetingMobs)

		remove(afterMonsters, tFind(afterMonsters, monster))
		self.targetingMobs:set(afterMonsters)
	end
	Fusion.Hydrate(self.charData.TargetMonsters)({
		[Fusion.OnEvent("ChildAdded")] = _addMonster,
		[Fusion.OnEvent("ChildRemoved")] = _removeMonster
	})

    local monsterHPThread
	local function _combatStartSetup(monster: Model)
		if monsterHPThread then cancel(monsterHPThread) end
		if not monster then return end

		self.monsterHPPos:set(fromScale(0.015, -0.5))

		monsterHPThread = spawn(function()
			while true do
				self.monsterTargetingPos:set(fromScale(-0.225, 0.5))
				wait(0.6)
				self.monsterTargetingPos:set(fromScale(-0.2, 0.5))
				wait(0.6)
			end
		end)
	end
	local function _combatEndAction()
		if monsterHPThread then cancel(monsterHPThread) end

		self.monsterHPPos:set(fromScale(0.3, -0.5))
	end
	Fusion.Hydrate(self.char)({
		[Fusion.AttributeChange("InCombat")] = function(state: boolean)
			if state then
				_combatStartSetup(self.charData.TargetMonster.Value)

			elseif not state then
				_combatEndAction()
			end
		end
	})

    return Components.Frame({
        Name = "MobPhase",
        AnchorPoint = v2New(),
		ZIndex = 2,

        Position = Fusion.Tween(Fusion.Computed(function(use)
			return use(self.monsterHPPos)
		end), AssetBook.TweenInfos.half),

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.4, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(self.targetingMobs, function(_, mob: ObjectValue)
                return MobPhaseMobBar(mob.Value, self)
            end, Fusion.cleanup)
        }
    })
end

return MobPhase
