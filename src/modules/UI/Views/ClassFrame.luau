--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ActiveSlot = require(RepS.Modules.UI.Components.ActiveSlot)
local ClassSlot = require(RepS.Modules.UI.Components.ClassSlot)
local ClassInfo = require(RepS.Modules.UI.Components.ClassInfo)
local ExBindingBtn = require(RepS.Modules.UI.Components.ExBindingBtn)
local StatText = require(RepS.Modules.UI.Components.StatText)
local PassiveSlot = require(RepS.Modules.UI.Components.PassiveSlot)

local EffectsFrame = require(RepS.Modules.UI.Views.PlayerEffectsFrame)

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function ClassFrame(self: table) : Frame
    return Components.Frame({
        Name = "ClassFrame",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -1.15),

        [Fusion.Children] = {
            Components.Frame({
                BackgroundTransparency = 0.3,
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0),
                Size = fromScale(0.3, 1),
                [Fusion.Ref] = self.classFrame,

                [Fusion.Children] = {
                    Components.RoundUICorner(),

                    ActiveSlot(1, self),
                    ActiveSlot(2, self),
                    ActiveSlot(3, self),
                    ActiveSlot(4, self),

                    PassiveSlot(1, self),
                    PassiveSlot(2, self),
                    PassiveSlot(3, self),

                    ExBindingBtn("Menu", self),
                    ExBindingBtn("Backpack", self),

                    StatText("Left", "DMG", self),
                    StatText("Left", "Magic", self),
                    StatText("Right", "Gold", self),
                    StatText("Right", "RP", self),

                    ClassSlot(self),

                    ClassInfo(self, 1),
                    ClassInfo(self, 2),

                    EffectsFrame("Left", self),
                    EffectsFrame("Right", self)
                },
            }),
        },
    })
end

return ClassFrame
