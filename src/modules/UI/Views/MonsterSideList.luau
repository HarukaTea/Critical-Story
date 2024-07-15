--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local MonsterBar = require(RepS.Modules.UI.Components.MonsterBar)

local Children, peek = Fusion.Children, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait, spawn = task.wait, task.spawn
local insert, remove, tFind = table.insert, table.remove, table.find

local function MonsterSideList(self: table) : Frame
	local scope = self.scope :: Fusion.Scope

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
	table.insert(scope, self.charData.TargetMonsters.ChildAdded:Connect(_addMonster))
	table.insert(scope, self.charData.TargetMonsters.ChildRemoved:Connect(_removeMonster))

	local monsterHPTracker = Fusion.scoped({})
	local function _combatStartSetup(monster: Model)
		Fusion.doCleanup(monsterHPTracker)
		if not monster then return end

		table.insert(monsterHPTracker, spawn(function()
			while true do
				self.monsterTargetingPos:set(fromScale(-0.225, 0.5))
				wait(0.6)
				self.monsterTargetingPos:set(fromScale(-0.2, 0.5))
				wait(0.6)
			end
		end))
	end
	local function _combatEndAction()
		Fusion.doCleanup(monsterHPTracker)
	end
	table.insert(scope, HarukaLib:Hydrate(self.char, {
		["Attr-InCombat"] = function(state: boolean)
			if state then
				_combatStartSetup(self.charData.TargetMonster.Value)

			elseif not state then
				_combatEndAction()
			end
		end
	}))

    return Components.Frame(scope, {
        Name = "MonsterSideList",
        AnchorPoint = v2New(),
		ZIndex = 2,

		Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
			return if use(self.charStatsDict.IsInCombat) then fromScale(0.015, -2.8) else fromScale(0.5, -2.8)
		end), AssetBook.TweenInfos.half),

        [Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0.6, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(scope, self.targetingMobs, function(_, localScope: Fusion.Scope, obj: ObjectValue)
                return MonsterBar(obj.Value, self, localScope)
            end)
        }
    })
end

return MonsterSideList
