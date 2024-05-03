--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local TurnBaseMonsterBar = require(RepS.Modules.UI.Components.TurnBaseMonsterBar)
local TurnBasePlrBar = require(RepS.Modules.UI.Components.TurnBasePlrBar)

local Children, Hydrate, OnEvent, peek = Fusion.Children, Fusion.Hydrate, Fusion.OnEvent, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait, cancel, spawn = task.wait, task.cancel, task.spawn
local insert, remove, tFind = table.insert, table.remove, table.find

local function TurnBaseSideList(id: string, self: table) : Frame
	if id == "Monster" then
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
		Hydrate(self.charData.TargetMonsters)({
			[OnEvent("ChildAdded")] = _addMonster,
			[OnEvent("ChildRemoved")] = _removeMonster
		})


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
		Hydrate(self.char)({
			[Fusion.AttributeChange("InCombat")] = function(state: boolean)
				if state then
					_combatStartSetup(self.charData.TargetMonster.Value)

				elseif not state then
					_combatEndAction()
				end
			end
		})

	elseif id == "Player" then
		local function _addPlr(char: ObjectValue)
			wait()
			local nowPlayers = peek(self.playersInCombat)

			insert(nowPlayers, char)
			self.playersInCombat:set(nowPlayers)
		end
		local function _removePlr(char: ObjectValue)
			wait(1)
			local afterPlayers = peek(self.playersInCombat)

			remove(afterPlayers, tFind(afterPlayers, char))
			self.playersInCombat:set(afterPlayers)
		end

		local taggedMob = {}
		Hydrate(self.charData.TargetMonster)({
			[Fusion.OnChange("Value")] = function(newMob: Model?)
				if not newMob then return end

				self.targetingMob:set(newMob)

				if tFind(taggedMob, newMob) then return end
				if not newMob:FindFirstChild("TargetingList") then return end

				self.playersInCombat:set(newMob.TargetingList:GetChildren())
				taggedMob[#taggedMob + 1] = newMob

				Hydrate(newMob)({
					[OnEvent("ChildAdded")] = _addPlr,
					[OnEvent("ChildRemoved")] = _removePlr
				})
			end
		})
	end

    return Components.Frame({
        Name = id.."SideList",
        AnchorPoint = v2New(),
		ZIndex = 2,
		Position = fromScale(0.015 * (if id == "Player" then -1 else 1), -0.5),

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.6, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = if id == "Player" then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(if id == "Monster" then self.targetingMobs else self.playersInCombat, function(_, obj: ObjectValue)
                return if id == "Monster" then TurnBaseMonsterBar(obj.Value, self) else TurnBasePlrBar(obj.Value, self)
            end, Fusion.cleanup)
        }
    })
end

return TurnBaseSideList
