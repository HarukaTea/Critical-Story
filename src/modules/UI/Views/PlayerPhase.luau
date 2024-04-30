--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PlayerPhasePlrBar = require(RepS.Modules.UI.Components.PlayerPhasePlrBar)

local Children, Value, Hydrate, peek = Fusion.Children, Fusion.Value, Fusion.Hydrate, Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait = task.wait
local insert, remove, tFind = table.insert, table.remove, table.find

local function PlayerPhase(self: table) : Frame
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
            if newMob:FindFirstChild("TargetingList") then
                self.playersInCombat:set(newMob.TargetingList:GetChildren())

                taggedMob[#taggedMob + 1] = newMob

                Hydrate(newMob)({
                    [Fusion.OnEvent("ChildAdded")] = _addPlr,
                    [Fusion.OnEvent("ChildRemoved")] = _removePlr
                })
            end
        end
    })

	local function _combatStartSetup(monster: Model)
		if not monster then return end

		self.playersListPos:set(fromScale(-0.015, -0.5))
	end
	local function _combatEndAction()
		self.playersListPos:set(fromScale(-0.3, -0.5))
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
        Name = "PlayerPhase",
        AnchorPoint = v2New(),
        ZIndex = 2,

        Position = Fusion.Tween(Fusion.Computed(function(use)
			return use(self.playersListPos)
		end), AssetBook.TweenInfos.half),

        [Children] = {
            Fusion.New("UIListLayout")({
                Padding = udNew(0.4, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }),

            Fusion.ForValues(self.playersInCombat, function(_, char: ObjectValue)
                return PlayerPhasePlrBar(char.Value, self)
            end, Fusion.cleanup)
        }
    })
end

return PlayerPhase
