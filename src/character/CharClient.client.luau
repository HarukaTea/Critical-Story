--!nocheck

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players.LocalPlayer

local wait = task.wait

local function changeLocation(location: string)
    if not location or location == "" then return end

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
        if plr:GetAttribute("InCutscene") then return end

        local lightingInfo = AssetBook.LocationInfo[location].Lighting
        if lightingInfo then TS:Create(Lighting, AssetBook.TweenInfos.one, lightingInfo):Play() end
    end)
end
Add(HarukaLib:Hydrate(char, {
    ["Attr-CurrentRegion"] = changeLocation
}))
Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit:HasTag("IsZone") then char:SetAttribute("CurrentRegion", hit.Name) end
end))


local function dayNightCycle()
    if workspace:GetAttribute("WorldType") == "Everfrost" then return end

    local cycleTime, minutesInADay = 12 * 60, 24 * 60
    local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime
    local endTime = startTime + cycleTime
    local timeRatio, currentTime = minutesInADay / cycleTime, nil

    Add(HarukaLib.Clock(0.05, function()
        currentTime = tick()

        if currentTime > endTime then
            startTime = endTime
            endTime = startTime + cycleTime
        end

        Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
    end))
end
Spawn(dayNightCycle)

--// Clear
char.Humanoid.Died:Once(Empty)
