--!nocheck

local RunService = game:GetService("RunService")

local SerInt = 0

local Event = require(script.Parent.Parent.Event).Reliable

local wait = task.wait
local pack = string.pack

return function(Identifier: string): string
	assert(SerInt < 255, "reached max 255 identifiers.")

	if RunService:IsServer() then
		if not Event:GetAttribute(Identifier) then
			SerInt += 1
			Event:SetAttribute(Identifier, pack("I1", SerInt)) -- I1 -> 255 max, I2 -> ~ 6.5e4 max. (SerInt)
		end
	else
		while not Event:GetAttribute(Identifier) do
			wait(0.5)
		end
	end

	return Event:GetAttribute(Identifier)
end