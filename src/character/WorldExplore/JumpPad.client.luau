--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model
local plr = Players.LocalPlayer

local instanceNew = Instance.new
local wait = task.wait


--// Connections
local function bounce(hit: BasePart)
    if not hit:HasTag("Bounce") then return end

    local bp = instanceNew("BodyPosition")
    bp.Name = "Bouncer"
    bp.D = 800
    bp.Position = hit.Parent.Destination.Position
    bp.MaxForce = Vector3.one * 100000
    bp.Parent = char.PrimaryPart
    Debris:AddItem(bp, 1)

    workspace.Sounds.SFXs.Bounce:Play()

    repeat wait() until plr:DistanceFromCharacter(hit.Parent.Destination.Position) <= 5

    if bp then bp:Destroy() end
end
Add(char.Humanoid.Touched:Connect(bounce))

--// Clear
char.Humanoid.Died:Once(Empty)
