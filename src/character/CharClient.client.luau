--!nocheck
--!optimize 2
--!native

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model

local wait = task.wait

local function changeLocation(location: string)
    if not location or location == "" then return end

    wait()
    Events.ChangePlayerLocation:Fire(location)

    --- sounds
    Spawn(function()
        local musicLib = workspace.Sounds.OverworldMusics :: Folder
        local overworldMusic = workspace.Sounds.Overworld :: Sound
        local targetSound = AssetBook.LocationInfo[location].Music

        if overworldMusic.SoundId ~= musicLib[targetSound].SoundId then
            TS:Create(overworldMusic, AssetBook.TweenInfos.half, { Volume = 0 }):Play()

            wait(0.6)
            overworldMusic.SoundId = musicLib[targetSound].SoundId
            overworldMusic:Play()

            if not overworldMusic.Playing then return end
            TS:Create(overworldMusic, AssetBook.TweenInfos.half, { Volume = AssetBook.LocationInfo[location].MusicVolume }):Play()
        end
    end)

    --- lighting
    Spawn(function()
        local lightingInfo = AssetBook.LocationInfo[location].Lighting

        if lightingInfo then TS:Create(Lighting, AssetBook.TweenInfos.one, lightingInfo):Play() end
    end)
end
HarukaLib:Hydrate(char, {
    ["Attr-CurrentRegion"] = changeLocation
})
