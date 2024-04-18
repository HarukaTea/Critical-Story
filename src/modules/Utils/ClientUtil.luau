--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Spawn = require(RepS.Modules.Packages.Spawn)

local cfNew = CFrame.new
local csNew = ColorSequence.new
local random = math.random
local wait = task.wait
local fromScale = UDim2.fromScale
local sFind = string.find

local ClientUtil = {}

--[[
    The class hit visual effects
]]
function ClientUtil:ClassHitVFX(monster: Model, char: Model)
    --- checks
    if not monster then return end
    if not monster.PrimaryPart then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if not plr then return end

    local class = plr:GetAttribute("Class") :: string
    if not AssetBook.ClassInfo[class] then return end

    --- main
    char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

    local color = AssetBook.ClassInfo[class].Color

    local hitEff = RepS.Package.Effects.HitEffect:Clone() :: Part
    hitEff.CFrame = monster.PrimaryPart.CFrame
    hitEff.Effect.Image.ImageColor3 = color
    hitEff.Particle.Color = csNew(color)
    hitEff.Effect.Image.Rotation = random(1, 360)
    if random(1, 2) == 1 then hitEff.Effect.Image.Image = "rbxassetid://2771196128" end
    hitEff.Parent = workspace

    Debris:AddItem(hitEff, 5)
    Debris:AddItem(hitEff.Particle, 2)

    Spawn(function()
        wait(0.2)
        hitEff.Particle.Enabled = false
    end)

    TS:Create(hitEff.Effect, AssetBook.TweenInfos.fourHalf, { Size = fromScale(30, 30) }):Play()
    TS:Create(hitEff.Effect.Image, AssetBook.TweenInfos.fourHalf, { ImageTransparency = 1 }):Play()
end

--[[
    Character was hit by mobs
]]
function ClientUtil:SetCharTrans(trans: number, char: Model)
    for _, child in char:GetChildren() do
		if child:IsA("Part") and child.Name ~= "HumanoidRootPart" then child.Transparency = trans end
		if child:IsA("Model") then
			for _, descendant in child:GetChildren() do
				if descendant.Name == "Part" then descendant.Transparency = trans end
			end
		end
		if child:IsA("Accessory") then child.Handle.Transparency = trans end
	end
end

--[[
    Get all key locations in story
]]
function ClientUtil:GetKeyStoryLocations() : table
    local pos = {}

    for _, child in workspace:WaitForChild("MapComponents").NPCs:GetChildren() do
        pos[child.Name] = child.PrimaryPart.Position
    end
    for _, child in workspace.MapComponents.Statues:GetChildren() do
        pos[child.Name] = child.PrimaryPart.Position
    end
    for _, child in workspace:GetDescendants() do
        if sFind(child.Name, "StoryLocator") then
            local map, locator = child.Parent.Name, child.Name

            if not pos[map] then pos[map] = {} end

            pos[map][locator] = child.Position
        end
    end

    return pos
end

return ClientUtil
