--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Tween, Computed, Value = Fusion.New, Fusion.Tween, Fusion.Computed, Fusion.Value

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI

local fromScale = UDim2.fromScale
local udNew, ud2New = UDim.new, UDim2.new
local tFind = table.find
local format = string.format
local wait, spawn, cancel = task.wait, task.spawn, task.cancel
local fromRGB = Color3.fromRGB

local function TurnBaseTimer(self: table) : Frame
    self.timerPos = Value(ud2New(0.5, 0, -1, -50))
    self.timerTime = Value(15)

    local blacklist = { "Mob", "Ally", "Execution" }
    local countdownThread: thread = nil
    local function newPhaseStarted(phase: string)
        if tFind(blacklist, phase) then
            self.timerPos:set(ud2New(0.5, 0, -1, -50))
            self.panelPos:set(fromScale(0.5, 5))
            self.transHPBarSize:set(fromScale(0, 0.875))

            if countdownThread then cancel(countdownThread) end
            return
        end

        self.timerTime:set(15)
        self.timerPos:set(ud2New(0.5, 0, 0.5, -50))

        if countdownThread then cancel(countdownThread) end
        countdownThread = spawn(function()
            for i = Fusion.peek(self.timerTime), 1, -1 do
                self.timerTime:set(i)
                wait(1)
            end

            self.timerPos:set(ud2New(0.5, 0, -1, -50))
        end)
    end
    Events.NewPhase:Connect(newPhaseStarted)

    return Components.Frame({
        Name = "Timer",
        Size = fromScale(0.1, 0.7),
        BackgroundTransparency = 0,

        Position = Tween(Computed(function(use)
            return use(self.timerPos)
        end), AssetBook.TweenInfos.twiceHalfOne),

        [Fusion.Children] = {
            Components.RoundUICorner(),
            Components.UIStroke({
                Enabled = true,
                Thickness = 2.7,
            }),
            Components.TextLabel({
                Name = "Time",
                Size = fromScale(1, 1),

                Text = Computed(function(use)
                    return "0:" .. format("%02d", use(self.timerTime))
                end),
                TextColor3 = Tween(Computed(function(use)
                    return if use(self.timerTime) > 3 then fromRGB(255, 255, 255) else fromRGB(255, 0, 0)
                end)),

                [Fusion.Children] = {
                    New("UIPadding")({
                        PaddingBottom = udNew(0.05, 0),
                        PaddingTop = udNew(0.05, 0)
                    })
                }
            })
        }
    })
end

return TurnBaseTimer
