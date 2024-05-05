--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Fusion = require(RepS.Modules.Packages.Fusion)

local char = script.Parent.Parent.Parent :: Model

script:SetAttribute("Turn", math.huge)

Fusion.Hydrate(script)({
	[Fusion.AttributeChange("Turn")] = function()
        BuffEffectsUtil:Heal(char, 0.5)
	end
})
