--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function LevelUpVFXFrame(self: table) : Frame
    return Components.Frame({
        Name = "LevelUPVFX",
        Visible = Computed(function(use)
            return use(self.levelUpShown)
        end),

        [Children] = {
            Components.Frame({
                Name = "Level",
                AnchorPoint = v2New(0.5, 0),
                Position = Fusion.Tween(Computed(function(use)
                    return use(self.levelUpPos)
                end), AssetBook.TweenInfos.half),
                Size = fromScale(0.039, 1),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(),
                    Components.UIStroke({
                        Thickness = 3,
                        Enabled = true
                    }),
                    Components.CenterTextLabel({
                        Name = "Stat",
                        Position = fromScale(0.5, 0.5),
                        Size = fromScale(0.7, 0.7),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Text = Computed(function(use)
                            return use(self.charStatsDict.PlayerData.Levels)
                        end)
                    })
                }
            }),
            Components.TextLabel({
                Name = "LevelUPTitle",
                Position = fromScale(0.468, 0.149),
                Size = fromScale(0.15, 0.615),
                Visible = Computed(function(use)
                    return use(self.levelUpTitleShown)
                end),
                Text = "LEVEL UP!",
                TextColor3 = fromRGB(255, 255, 0),
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = { Components.TextUIStroke({ Thickness = 2.5 }) }
            })
        },
    })
end

return LevelUpVFXFrame
