--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local function TurnBaseCriTiming(self: table) : Frame
    HarukaLib:Hydrate(self.plr, {
        ["Attr-Class"] = function(newClass: string)
            self.playerClass:set(newClass)
        end
    })

    return Components.Frame({
        Name = "CriTimingBar",
        AnchorPoint = v2New(0.5, 0),
        Position = fromScale(0.5, -2.5),
        Size = fromScale(0.5, 1.5),

        Visible = Computed(function(use)
            return use(self.isInAttackPhase)
        end),

        [Children] = {
            New("Frame")({
                Name = "Left",
                Size = fromScale(0.5, 1),
                Rotation = 180,

                [Children] = { Components.UIGradient() }
            }),
            New("Frame")({
                Name = "Right",
                Size = fromScale(0.5, 1),
                Position = fromScale(0.5, 0),

                [Children] = { Components.UIGradient() }
            }),

            Components.Frame({
                Name = "PerfectTiming",
                BackgroundTransparency = 0.5,
                Size = fromScale(0.027, 1),

                Position = Computed(function(use)
                    return use(self.criBarPos)
                end),

                [Children] = {
                    Components.UIStroke({
                        Thickness = 3,

                        Color = Computed(function(use)
                            return AssetBook.ClassInfo[use(self.playerClass)].Color
                        end)
                    })
                }
            }),
            New("Frame")({
                Name = "Timing",
                BackgroundTransparency = 0.6,
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0, 0.5),
                Size = fromScale(0.025, 1.15)
            })
        }
    })
end

return TurnBaseCriTiming
