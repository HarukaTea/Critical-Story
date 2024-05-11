--!nocheck
--!optimize 2
--!native

local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Atmosphere = require(RepS.Modules.Packages.Atmosphere)
local Signals = require(RepS.Modules.Data.Signals)

local plr = Players.LocalPlayer

local instanceNew = Instance.new
local v3New = Vector3.new
local wait = task.wait

--// Effects init

--- effects fade
local function fadeEffect(effect: ParticleEmitter)
    wait(0.4)
    pcall(function()
        effect.Enabled = false
    end)
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
    Atmosphere.WindLines:Init({
        Direction = v3New(1, 0, 0.3),
        Speed = 25,
        LifeTime = 0.8,
        SpawnRate = 5,
    })

    --- wind shakes
    Atmosphere.WindShake:SetDefaultSettings({
        WindSpeed = 20,
        WindDirection = v3New(1, 0, 0.3),
        WindPower = 0.5
    })
    Atmosphere.WindShake:Init()
    for _, child: Instance in workspace:GetDescendants() do
        if child:IsA("Model") and child.Name == "Tree" then
            for _, treePart: BasePart in child:GetChildren() do
                if treePart.Material == Enum.Material.Grass then Atmosphere.WindShake:AddObjectShake(treePart) end
            end
        end
    end
end
--- wind lines
enableWinds()

local function toggleWinds(action: string)
    if action == "Enable" then
        plr.Character.WorldClientAnims.Disabled = false

        enableWinds()
    else
        Atmosphere.WindLines:Cleanup()
        Atmosphere.WindShake:Cleanup()

        plr.Character.WorldClientAnims.Disabled = true
    end
end
Signals.EnableMapDetails:Connect(toggleWinds)
