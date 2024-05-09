--!nocheck
--!optimize 2
--!native

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
local wait, cancel, spawn = task.wait, task.cancel, task.spawn
local insert, remove, tFind = table.insert, table.remove, table.find

local function MonsterSideList(self: table) : Frame
	local scope = self.scope

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
	self.Add(self.charData.TargetMonsters.ChildAdded:Connect(_addMonster))
	self.Add(self.charData.TargetMonsters.ChildRemoved:Connect(_removeMonster))

	local monsterHPThread: thread = nil
	local function _combatStartSetup(monster: Model)
		if monsterHPThread then cancel(monsterHPThread) end
		if not monster then return end

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
	end
	self.Add(HarukaLib:Hydrate(self.char, {
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

		Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
			return if use(self.charStatsDict.IsInCombat) then fromScale(0.015, -4.5) else fromScale(0.5, -4.5)
		end), AssetBook.TweenInfos.half),

        [Children] = {
            Fusion.New(scope, "UIListLayout")({
                Padding = udNew(0.6, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(scope, self.targetingMobs, function(_, localScope: table, obj: ObjectValue)
                return MonsterBar(obj.Value, self, localScope)
            end)
        }
    })
end

return MonsterSideList
