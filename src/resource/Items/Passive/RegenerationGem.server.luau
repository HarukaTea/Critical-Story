--!nocheck

local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)

local char = script.Parent.Parent.Parent :: Model

local wait = task.wait

while wait(15) do BuffEffectsUtil:Heal(char, 0.1) end
