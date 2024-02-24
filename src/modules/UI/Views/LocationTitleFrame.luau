--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children, Tween, Computed, Value = Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.Value

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait, cancel, spawn = task.wait, task.cancel, task.spawn

local function TextStroke(self: table)
    return Components.TextUIStroke({
        Thickness = 2,
        Transparency = Tween(Computed(function(use)
            return use(self.locationInfo.OverallStrokeTrans)
        end), AssetBook.TweenInfos.half)
    })
end

local function LocationTitleFrame(self: table) : Frame
    self.locationInfo = {
		Thread = nil,
		Name = Value(""),
		Desc = Value(""),
		Shown = Value(false),
		OverallTrans = Value(1),
		OverallStrokeTrans = Value(1),
		HorizonLineSize = Value(fromScale(0.25, 0.07))
	}
    local function _showCurrentLocation(location: string)
        if not location or location == "" then return end
		local locationInfo = self.locationInfo

		if locationInfo.Thread then cancel(locationInfo.Thread) end

		wait()
		locationInfo.Thread = spawn(function()
            Spawn(function()
                local overworldMusic = workspace.Sounds.Overworld :: Sound
                if overworldMusic.SoundId ~= AssetBook.LocationInfo.Music[location] then
                    TS:Create(overworldMusic, AssetBook.TweenInfos.half, { Volume = 0 }):Play()

                    wait(0.6)
                    overworldMusic.SoundId = AssetBook.LocationInfo.Music[location]
                    overworldMusic:Play()

                    if not overworldMusic.Playing then return end
                    TS:Create(overworldMusic, AssetBook.TweenInfos.half, { Volume = AssetBook.LocationInfo.MusicVolumes[overworldMusic.SoundId] }):Play()
                end
            end)

			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
			locationInfo.Shown:set(true)

			wait(0.3)
			locationInfo.OverallStrokeTrans:set(0.3)
			locationInfo.OverallTrans:set(0)

			locationInfo.Name:set(AssetBook.LocationInfo.Name[location])
			locationInfo.Desc:set(AssetBook.LocationInfo.Desc[location])

			wait(0.1)
			locationInfo.HorizonLineSize:set(fromScale(0, 0.07))

			wait(2)
			locationInfo.OverallStrokeTrans:set(1)
			locationInfo.OverallTrans:set(1)

			wait(1)
			locationInfo.Shown:set(false)
			locationInfo.HorizonLineSize:set(fromScale(0.25, 0.07))
		end)
	end
    Fusion.Hydrate(self.char)({
        [Fusion.AttributeChange("CurrentRegion")] = _showCurrentLocation
    })

    return Components.Frame({
        Name = "LocationTitle",
        Visible = Computed(function(use)
            return use(self.locationInfo.Shown)
        end),

        [Children] = {
            Components.TextLabel({
                Name = "Title",
                Text = "Now Entering Area :",
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