--!nocheck

local FastSpawn = require(script.Parent.Parent["red-blox_spawn"].spawn)

local HarukaLib = {}

local floor, log10 = math.floor, math.log10
local format = string.format

--[[
	Convert a number to string with abbr, for example, `10000` -> `10K`
]]
function HarukaLib:NumberConvert(number: number, type: string) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = floor(floor(log10(number)) / 3)

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return format(type, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		else
			return tostring(number)
		end
	else
		return tostring(number)
	end
end

--[[
	Update an attribute to a given value, equals to `Value += val`
]]
function HarukaLib:Add(obj: Instance, attribute: string, val: number)
	obj:SetAttribute(attribute, obj:GetAttribute(attribute) + val)
end

--[[
	Clear all attributes from an instance, equals to `obj:ClearAllChildren()`
]]
function HarukaLib:ClearAllAttributes(obj: Instance)
	for attribute, _ in obj:GetAttributes() do
		obj:SetAttribute(attribute, nil)
	end
end

--[[
	To prevent require issues
]]
function HarukaLib:Require(list: table, plr: Player)
	for _, module in list do
		FastSpawn(function()
			require(module)(plr)
		end)
	end
end

return HarukaLib
