--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Fusion = HarukaFrameworkClient.Fusion

local Children, Tween, Computed = Fusion.Children, Fusion.Tween, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local function TextStroke(self: table)
    return Components.TextUIStroke({
        Thickness = 2,
        Transparency = Tween(Computed(function(use)
            return use(self.locationInfo.OverallStrokeTrans)
        end), AssetBook.TweenInfos.half)
    })
end

local function LocationTitleFrame(self: table) : Frame
    return Components.Frame({
        Name = "LocationTitle",
        Visible = Computed(function(use)
            return use(self.locationInfo.Shown)
        end),

        [Children] = {
            Components.TextLabel({
                Name = "Title",
                Text = "Now  Entering  Area :",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0),
                Size = fromScale(1, 0.45),
                TextTransparency = Tween(Computed(function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
            Components.TextLabel({
                Name = "LocationName",
                Text = Computed(function(use)
                    return use(self.locationInfo.Name)
                end),
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(1, 0.6),
                TextColor3 = fromRGB(74, 222, 109),
                TextTransparency = Tween(Computed(function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
            Fusion.New("Frame")({
                Name = "HorizonLine",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 1.4),
                Size = Fusion.Tween(Computed(function(use)
                    return use(self.locationInfo.HorizonLineSize)
                end), AssetBook.TweenInfos.two),
                BackgroundTransparency = Tween(Computed(function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { Components.RoundUICorner() }
            }),
            Components.TextLabel({
                Name = "LocationDesc",
                Text = Computed(function(use)
                    return use(self.locationInfo.Desc)
                end),
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 1.7),
                Size = fromScale(1, 0.45),
                TextTransparency = Tween(Computed(function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
        }
    })
end

return LocationTitleFrame