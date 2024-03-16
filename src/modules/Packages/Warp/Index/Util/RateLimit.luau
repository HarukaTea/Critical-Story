--!strict

local RateLimit = {}

local RunService = game:GetService("RunService")

local Event = require(script.Parent.Parent.Event).Reliable

local delay, wait = task.delay, task.wait

function RateLimit.create(Identifier: string, entrance: number?, interval: number?)
	if RunService:IsServer() then
		assert(typeof(entrance) == "number", "entrance must a number type.")
		assert(entrance :: number > 0, "entrance must above 0.")

		Event:SetAttribute(Identifier.."_ent", entrance)
		Event:SetAttribute(Identifier.."_int", interval)
	else
		while (not Event:GetAttribute(Identifier.."_ent")) or (not Event:GetAttribute(Identifier.."_int")) do
			wait(0.5)
		end
		entrance = tonumber(Event:GetAttribute(Identifier.."_ent"))
		interval = tonumber(Event:GetAttribute(Identifier.."_int"))
	end

	local entrances: number = 0
	return function(incoming: number?): boolean
		if entrances == 0 then
			delay(interval, function()
				entrances = 0
			end)
		end
		entrances += incoming and incoming or 1
		return (entrances <= entrance :: number)
	end
end

return RateLimit :: typeof(RateLimit)
