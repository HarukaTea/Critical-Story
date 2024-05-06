--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local char = script.Parent.Parent.Parent :: Model

script:SetAttribute("Turn", math.huge)

HarukaLib:Hydrate(script, {
	["Attr-Turn"] = function()
		BuffEffectsUtil:Heal(char, 0.5)
	end
})
