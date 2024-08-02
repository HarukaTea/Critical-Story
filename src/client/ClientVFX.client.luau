--!nocheck

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Signals = require(RepS.Modules.Data.Signals)
local WindLines = require(RepS.Modules.Packages.Atmosphere.WindLines)
local WindShake = require(RepS.Modules.Packages.Atmosphere.WindShake)

local instanceNew = Instance.new
local v3New = Vector3.new
local wait = task.wait

--// Effects init

--- vfxs
local function emitVFX(effect: ParticleEmitter)
    wait()
    effect:Emit(tonumber(effect:GetAttribute("EmitCount") or 5))
end
CS:GetInstanceAddedSignal("VFX"):Connect(emitVFX)

--- effects fade
local function fadeEffect(effect: ParticleEmitter)
    wait(0.4)
    if effect then effect.Enabled = false end
end
CS:GetInstanceAddedSignal("GlobalEffects"):Connect(fadeEffect)

--- text fade
local function fadeText(text: BasePart)
    wait()
    local bv = instanceNew("BodyVelocity")
    bv.MaxForce = v3New(1, 1, 1) * (10 * 10 ^ 10)
    bv.Velocity = v3New(0, 5, 0)
    bv.Parent = text

    wait(1)
    pcall(function()
        TS:Create(text.Display.Text, AssetBook.TweenInfos.half, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
    end)
end
CS:GetInstanceAddedSignal("TextEffects"):Connect(fadeText)

--// Atmopshere init

local function enableWinds()
    WindLines:Init({
        Direction = v3New(1, 0, 0.3),
        Speed = 25,
        LifeTime = 0.8,
        SpawnRate = 5,
    })

    --- wind shakes
    WindShake:Init({
        WindSpeed = 20,
        WindDirection = v3New(1, 0, 0.3),
        WindPower = 0.5
    })

    for _, child: Instance in workspace:WaitForChild("Maps", 999):GetDescendants() do
        if child:IsA("Model") and string.find(child.Name, "Tree") then
            for _, treePart: BasePart in child:GetDescendants() do
                if not treePart:IsA("BasePart") then continue end

                if treePart.Material == Enum.Material.Grass then WindShake:AddObjectShake(treePart) end
            end
        end
    end
    for _, child: Instance in RepS.Debris.Trees:GetChildren() do
        if child:IsA("Model") and string.find(child.Name, "Tree") then
            for _, treePart: BasePart in child:GetDescendants() do
                if not treePart:IsA("BasePart") then continue end

                if treePart.Material == Enum.Material.Grass then WindShake:AddObjectShake(treePart) end
            end
        end
    end
end
--- wind lines
enableWinds()

local function toggleWinds(action: string)
    if action == "Enable" then
        enableWinds()
    else
        WindLines:Cleanup()
        WindShake:Cleanup()
    end
end
Signals.EnableMapDetails:Connect(toggleWinds)
