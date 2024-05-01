--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)

local New, Tween, Computed = Fusion.New, Fusion.Tween, Fusion.Computed

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local wait = task.wait
local tFind = table.find

local function TurnBasePhaseShower(self: table) : Frame
	local phaseInfo = {
		Player = {
			Color = fromRGB(85, 255, 255),
			Text = "PLAYER PHASE"
		},
		Combat = {
			Color = fromRGB(255, 255, 0),
			Text = "COMBAT START!"
		},
		Mob = {
			Color = fromRGB(255, 85, 127),
			Text = "ENEMY PHASE"
		},
        Ally = {
            Color = fromRGB(0, 255, 0),
            Text = "ALLY PHASE"
        }
	}

    local blacklist = { "Execution" }
    local function enteringNewPhase(phase: string)
        if tFind(blacklist, phase) then return end

        self.phaseBarTweenInfo:set(AssetBook.TweenInfos.fourHalf)
        self.phaseBarProgress:set(fromScale(1, 1))
        Spawn(function()
            wait(0.05)
            self.phaseBarTweenInfo:set(AssetBook.TweenInfos.fifteen)
            self.phaseBarProgress:set(fromScale(0, 1))
        end)

		self.currentPhase:set(phase)
		self.phaseTrans:set(0)
		Spawn(function()
			wait(1.2)
			self.phaseTrans:set(1)
		end)

		if Fusion.peek(self.phasePos[1]) == fromScale(-0.2, 0) then
			self.phasePos[1]:set(fromScale(1.2, 0))
			self.phasePos[2]:set(fromScale(-0.2, 0.9))
		else
			self.phasePos[1]:set(fromScale(-0.2, 0))
			self.phasePos[2]:set(fromScale(1.2, 0.9))
		end
	end
	Events.NewPhase:Connect(enteringNewPhase)

    return Components.Frame({
        Name = "PhaseShower",
        Size = fromScale(1, 0.8),

        BackgroundTransparency = Tween(Computed(function(use)
            return use(self.phaseTrans)
        end), AssetBook.TweenInfos.twiceHalfOne),

        [Fusion.Children] = {
            Components.TextLabel({
                Name = "Phase",
                Size = fromScale(1, 1),

                TextColor3 = Computed(function(use)
                    return phaseInfo[use(self.currentPhase)].Color
                end),
                Text = Computed(function(use)
                    return phaseInfo[use(self.currentPhase)].Text
                end),
                TextTransparency = Tween(Computed(function(use)
                    return use(self.phaseTrans)
                end), AssetBook.TweenInfos.twiceHalfOne),

                [Fusion.Children] = {
                    New("UIPadding")({
                        PaddingTop = udNew(0.1, 0),
                        PaddingBottom = udNew(0.1, 0)
                    }),
                }
            }),
            New("Frame")({
                Name = "TopBar",
                Size = fromScale(0.15, 0.1),

                BackgroundTransparency = Tween(Computed(function(use)
                    return use(self.phaseTrans)
                end), AssetBook.TweenInfos.twiceHalfOne),
                Position = Tween(Computed(function(use)
                    return use(self.phasePos[1])
                end), AssetBook.TweenInfos.two)
            }),
            New("Frame")({
                Name = "BottomBar",
                Size = fromScale(0.15, 0.1),

                BackgroundTransparency = Tween(Computed(function(use)
                    return use(self.phaseTrans)
                end), AssetBook.TweenInfos.twiceHalfOne),
                Position = Tween(Computed(function(use)
                    return use(self.phasePos[2])
                end), AssetBook.TweenInfos.two)
            }),
        }
    })
end

return TurnBasePhaseShower
