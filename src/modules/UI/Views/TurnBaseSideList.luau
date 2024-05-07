--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local TurnBaseMonsterBar = require(RepS.Modules.UI.Components.TurnBaseMonsterBar)
local TurnBasePlrBar = require(RepS.Modules.UI.Components.TurnBasePlrBar)

local Children, peek = Fusion.Children, Fusion.peek

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
		HarukaLib:Hydrate(self.charData.TargetMonsters, {
			["ChildAdded"] = _addMonster,
			["ChildRemoved"] = _removeMonster
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
		HarukaLib:Hydrate(self.char, {
			["Attr-InCombat"] = function(state: boolean)
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
		HarukaLib:Hydrate(self.charData.TargetMonster, {
			["Prop-Value"] = function(newMob: Model?)
				if not newMob then return end

				self.targetingMob:set(newMob)

				if tFind(taggedMob, newMob) then return end
				if not newMob:FindFirstChild("TargetPlayers") then return end

				self.playersInCombat:set(newMob.TargetPlayers:GetChildren())
				taggedMob[#taggedMob + 1] = newMob

				HarukaLib:Hydrate(newMob.TargetPlayers, {
					["ChildAdded"] = _addPlr,
					["ChildRemoved"] = _removePlr
				})
			end
		})

		local playerHPThread: thread = nil
		local function _combatStartSetup()
			if playerHPThread then cancel(playerHPThread) end

			playerHPThread = spawn(function()
				while true do
					self.playerTargetingPos:set(fromScale(1.075, 0.5))
					wait(0.6)
					self.playerTargetingPos:set(fromScale(1.05, 0.5))
					wait(0.6)
				end
			end)
		end
		local function _combatEndAction()
			if playerHPThread then cancel(playerHPThread) end
		end
		HarukaLib:Hydrate(self.char, {
			["Attr-InCombat"] = function(state: boolean)
				if state then
					self.targetingPlayer:set(Players.LocalPlayer)

					_combatStartSetup()

				elseif not state then
					_combatEndAction()
				end
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
