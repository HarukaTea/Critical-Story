--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children, Tween, Computed = Fusion.Children, Fusion.Tween, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait, cancel, spawn = task.wait, task.cancel, task.spawn

local function TextStroke(self: table)
    return Components.TextUIStroke(self.scope, {
        Thickness = 2,

        Transparency = Tween(self.scope, Computed(self.scope, function(use)
            return use(self.locationInfo.OverallStrokeTrans)
        end), AssetBook.TweenInfos.half)
    })
end

local function LocationTitleFrame(self: table) : Frame
    local scope = self.scope

    local function _showCurrentLocation(location: string)
        if not location or location == "" then return end
		local locationInfo = self.locationInfo

		if locationInfo.Thread then cancel(locationInfo.Thread) end

		locationInfo.Thread = spawn(function()
            locationInfo.HorizonLineTweenInfo:set(AssetBook.TweenInfos.half)
			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
			locationInfo.Shown:set(true)
            locationInfo.Name:set(AssetBook.LocationInfo[location].Name)
			locationInfo.Desc:set(AssetBook.LocationInfo[location].Desc)

			wait(0.3)
			locationInfo.OverallStrokeTrans:set(0.3)
			locationInfo.OverallTrans:set(0)

			wait(0.1)
            locationInfo.HorizonLineTweenInfo:set(AssetBook.TweenInfos.two)
			locationInfo.HorizonLineSize:set(fromScale(0, 0.07))

			wait(2)
			locationInfo.OverallStrokeTrans:set(1)
			locationInfo.OverallTrans:set(1)

			wait(1)
			locationInfo.Shown:set(false)
            locationInfo.HorizonLineTweenInfo:set(AssetBook.TweenInfos.half)
			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
		end)
	end
    self.Add(HarukaLib:Hydrate(self.char, {
        ["Attr-CurrentRegion"] = _showCurrentLocation
    }))

    return Components.Frame(scope, {
        Name = "LocationTitle",
        Visible = Computed(scope, function(use)
            return use(self.locationInfo.Shown)
        end),

        [Children] = {
            Components.TextLabel(scope, {
                Name = "Title",
                Text = "Entering Area:",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0),
                Size = fromScale(1, 0.45),
                TextTransparency = Tween(scope, Computed(scope, function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
            Components.TextLabel(scope, {
                Name = "LocationName",
                Text = Computed(scope, function(use)
                    return use(self.locationInfo.Name)
                end),
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 0.6),
                Size = fromScale(1, 0.6),
                TextColor3 = fromRGB(74, 222, 109),

                TextTransparency = Tween(scope, Computed(scope, function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
            Fusion.New(scope, "Frame")({
                Name = "HorizonLine",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 1.4),

                Size = Tween(scope, Computed(scope, function(use)
                    return use(self.locationInfo.HorizonLineSize)
                end), self.locationInfo.HorizonLineTweenInfo),
                BackgroundTransparency = Tween(scope, Computed(scope, function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "LocationDesc",
                Text = Computed(scope, function(use)
                    return use(self.locationInfo.Desc)
                end),
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.5, 1.7),
                Size = fromScale(1, 0.45),

                TextTransparency = Tween(scope, Computed(scope, function(use)
                    return use(self.locationInfo.OverallTrans)
                end), AssetBook.TweenInfos.half),

                [Children] = { TextStroke(self) }
            }),
        }
    })
end

return LocationTitleFrame