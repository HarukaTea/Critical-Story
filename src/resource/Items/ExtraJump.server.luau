--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent.Parent.Parent :: Model
local plr = game:GetService("Players"):GetPlayerFromCharacter(char)

local fromRGB = Color3.fromRGB
local instanceNew = Instance.new
local v3New = Vector3.new
local cfNew = CFrame.new

local ITEM_ATTRIBUTES = { CD = 7 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script) == false then return end

---
ServerUtil:ShowText(char, "Extra Jump!", fromRGB(255, 255, 255))

local bv = instanceNew("BodyVelocity")
bv.P = math.huge
bv.MaxForce = v3New(0, math.huge, 0)
bv.Velocity = v3New(0, char.Humanoid.JumpPower * 1.1, 0)
bv.Parent = char.PrimaryPart
Debris:AddItem(bv, 0.05)

local eff = RepS.Package.MagicAssets.JumpEffect:Clone() :: UnionOperation
eff.CFrame = char.PrimaryPart.CFrame * cfNew(0, -1.5, 0)
eff.Parent = workspace
Debris:AddItem(eff, 1)

Events.ClientTween:Fires({ eff }, { Size = v3New(23, 15, 23), Transparency = 1 }, "threeHalf")
