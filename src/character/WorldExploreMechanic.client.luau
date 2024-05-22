--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players.LocalPlayer

local instanceNew = Instance.new
local v3New = Vector3.new
local wait = task.wait


--// Connections
local function bounce(hit: BasePart)
    if not hit:HasTag("Bounce") then return end

    local humanoid = char.Humanoid :: Humanoid

    humanoid.Sit = true

    local bp = instanceNew("BodyPosition")
    bp.Name = "Bouncer"
    bp.D = 800
    bp.Position = hit:GetAttribute("TargetPos")
    bp.MaxForce = v3New(1, 1, 1) * 100000
    bp.Parent = char.Humanoid.RootPart
    Debris:AddItem(bp, 1)

    Signals.PlayAnimation:Fire("Bounce")
    workspace.Sounds.SFXs.Bounce:Play()

    repeat wait() until plr:DistanceFromCharacter(hit:GetAttribute("TargetPos")) <= 5

    humanoid.PlatformStand = false
    humanoid.Sit = false

    if bp then bp:Destroy() end
end
Add(char.Humanoid.Touched:Connect(bounce))

--// Clear
char.Humanoid.Died:Once(Empty)
