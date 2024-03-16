--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local MonsterHPBar = require(RepS.Modules.UI.Components.MonsterHPFrame)

local Children, New, Value, peek = Fusion.Children, Fusion.New, Fusion.Value, Fusion.peek

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local cancel, spawn, wait = task.cancel, task.spawn, task.wait
local insert, tFind, remove = table.insert, table.find, table.remove

local function MonsterHPFrame(self: table) : Frame
    self.monsterHPPos, self.monsterTargetingPos = Value(fromScale(0.9, -0.3)), Value(fromScale(-0.15, 0))

    local monsterHPThread
	local function _combatStartSetup(monster: Model)
		if monsterHPThread then cancel(monsterHPThread) end
		if not monster then return end

		self.monsterHPPos:set(fromScale(0.5, -0.3))

		monsterHPThread = spawn(function()
			while true do
				self.monsterTargetingPos:set(fromScale(-0.16, 0))
				wait(0.6)
				self.monsterTargetingPos:set(fromScale(-0.15, 0))
				wait(0.6)
			end
		end)
	end
	local function _combatEndAction()
		if monsterHPThread then cancel(monsterHPThread) end

		self.monsterHPPos:set(fromScale(1.5, -0.3))
	end
	Fusion.Hydrate(self.char)({
		[Fusion.AttributeChange("InCombat")] = function(state)
			if state then
				_combatStartSetup(self.charData.TargetMonster.Value)

			elseif not state then
				_combatEndAction()
			end
		end
	})

    local function _addMonster(monster: ObjectValue)
		wait()
		local nowMonsters = peek(self.charStatsDict.MonsterAmount)

		insert(nowMonsters, monster)
		self.charStatsDict.MonsterAmount:set(nowMonsters)
	end
	local function _removeMonster(monster: ObjectValue)
		local monsters = peek(self.charStatsDict.MonsterAmount)
		if monster == monsters[self.nowMobIndex] then self.nowMobIndex = 1 end

		wait(1)
		local afterMonsters = peek(self.charStatsDict.MonsterAmount)

		remove(afterMonsters, tFind(afterMonsters, monster))
		self.charStatsDict.MonsterAmount:set(afterMonsters)
	end
	Fusion.Hydrate(self.charData.TargetMonsters)({
		[Fusion.OnEvent("ChildAdded")] = _addMonster,
		[Fusion.OnEvent("ChildRemoved")] = _removeMonster
	})

    return Components.Frame({
        Name = "MonsterHPFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = Fusion.Tween(
            Fusion.Computed(function(use)
                return use(self.monsterHPPos)
            end),
            AssetBook.TweenInfos.half
        ),
        Size = fromScale(1, 1.085),

        [Children] = {
            New("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = udNew(0.15, 0),
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
            }),
            Fusion.ForValues(self.charStatsDict.MonsterAmount, function(use, symbol: ObjectValue)
                local monster = symbol.Value :: Model

                local info = {
                    Model = monster,
                    HP = Value(monster:GetAttribute("Health")),
                    MaxHP = Value(monster:GetAttribute("MaxHealth")),
                    Name = monster.Name,
                    Level = monster:GetAttribute("Levels"),
                    Avatar = AssetBook.MonsterAvatars[monster.Name],
                    EffectsList = Value({}),
                    Targeting = if self.charData.TargetMonster.Value == monster
                        then Value(true)
                        else Value(false),
                }

                return MonsterHPBar(info, self)
            end, Fusion.cleanup),
        },
    })
end

return MonsterHPFrame