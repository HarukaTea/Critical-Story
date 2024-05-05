--!nocheck
--!optimize 2
--!native

local CS = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.Modules.Data.AssetBook)

local instanceNew = Instance.new
local v3New = Vector3.new
local wait = task.wait

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
