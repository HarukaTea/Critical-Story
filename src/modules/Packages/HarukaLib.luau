--!nocheck

local HarukaLib = {}

local floor, log10, abs = math.floor, math.log10, math.abs
local format = string.format
local cfNew, v3New, fromRGB = CFrame.new, Vector3.new, Color3.fromRGB
local unpack = table.unpack

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
	Whether it's in the region with the given Vector3
]]
function HarukaLib:IsInRegion(position: Vector3, regions: table) : BasePart
	local region: BasePart = nil

	for _, child in ipairs(regions) do
		local point = child.CFrame:PointToObjectSpace(position)

		if abs(point.X) < child.Size.X / 2 and abs(point.Y) < child.Size.Y / 2 and abs(point.Z) < child.Size.Z / 2 then
			region = child
			break
		end
	end

	return region
end

--[[
	A simple serializer for datastore
]]
function HarukaLib:Serialize(val: CFrame | Vector3 | Color3)
	local valType = typeof(val)

	if valType == "CFrame" then
		return { "CFrame", val:GetComponents() }

	elseif valType == "Vector3" then
		return { "Vector3", val.X, val.Y, val.Z }

	elseif valType == "Color3" then
		return { "Color3", val.R, val.G, val.B }

	else
		return val --- return default
	end
end
function HarukaLib:Deserialize(val: table)
	if typeof(val) ~= "table" then return val end

	local valType = val[1] :: string

	if valType == "CFrame" then
		return cfNew(unpack(val, 2, #val))

	elseif valType == "Vector3" then
		return v3New(unpack(val, 2, #val))

	elseif valType == "Color3" then
		return fromRGB(unpack(val, 2, #val))

	else
		return val
	end
end

return HarukaLib
