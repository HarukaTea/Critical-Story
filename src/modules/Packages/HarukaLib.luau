--!nocheck
--!optimize 2
--!native

local RS = game:GetService("RunService")

local HarukaLib = {}

local floor, log10, abs, random = math.floor, math.log10, math.abs, math.random
local format, gsub, sFind, sub = string.format, string.gsub, string.find, string.sub
local cfNew, v3New, fromRGB = CFrame.new, Vector3.new, Color3.fromRGB
local unpack, clear = table.unpack, table.clear
local spawn = task.spawn

--[[
	Convert a number to string with abbr, for example, `10000` -> `10K`
]]
function HarukaLib:NumberConvert(number: number, type: string) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = floor(floor(log10(number)) / 3)

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return format(type, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		end
	end

	return tostring(number)
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
	for attribute, _ in obj:GetAttributes() do obj:SetAttribute(attribute, nil) end
end

--[[
	Whether it's in the region with the given Vector3
]]
function HarukaLib:IsInRegion(position: Vector3, regions: table) : BasePart
	local region: BasePart = nil

	for _, child: BasePart in regions do
		local point = child.CFrame:PointToObjectSpace(position)

		if abs(point.X) < child.Size.X / 2 and abs(point.Y) < child.Size.Y / 2 and abs(point.Z) < child.Size.Z / 2 then
			region = child
			break
		end
	end

	return region
end

--[[
	Richtextify my self-created text format
]]
function HarukaLib:RichTextify(text: string) : string
	local colorList = {
		["<blue>"] = [[<font color="#70a1ff">]],
		["<purple>"] = [[<font color="#5352ed">]],
		["<red>"] = [[<font color="#ff4757">]],
		["<orange>"] = [[<font color="#ffa502">]],
		["<yellow>"] = [[<font color="#ffda79">]],
		["<green>"] = [[<font color="#7bed9f">]],
	}

	for oriTag: string, rbxColorTag: string in colorList do
		text = gsub(text, oriTag, rbxColorTag)
	end

	return text
end

--[[
	A simple serializer for datastore
]]
function HarukaLib:Serialize(val: CFrame | Vector3 | Color3) : any
	local valType = typeof(val)

	if valType == "CFrame" then
		return { "CFrame", val:GetComponents() }

	elseif valType == "Vector3" then
		return { "Vector3", floor(val.X), floor(val.Y), floor(val.Z) }

	elseif valType == "Color3" then
		return { "Color3", val.R, val.G, val.B }

	else
		return val --- return default
	end
end
function HarukaLib:Deserialize(val: table) : any
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

--[[
	A custom remade of `Fusion.Hydrate`, return a way to disconnect
]]
function HarukaLib:Hydrate(obj: Instance, props: table)
	local Add, Empty = HarukaLib.Bin()

	for prop, func in props do
		if sFind(prop, "Attr") then
			local _, endPos = sFind(prop, "Attr")
			local attr = sub(prop, endPos + 2)

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif sFind(prop, "Prop") then
			local _, endPos = sFind(prop, "Prop")
			local propName = sub(prop, endPos + 2)

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	obj.Destroying:Connect(Empty)

	return Empty
end

--[[
	A custom remade of `Bin`
]]
function HarukaLib.Bin()
	local bin = {}

	return function (item: any)
		bin[#bin + 1] = item

		return item

	end, function()
		for _, item: any in bin do
			if typeof(item) == "Instance" then
				item:Destroy()

			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()

			elseif typeof(item) == "function" then
				spawn(item)
			end
		end

		clear(bin)
	end
end

--[[
	A custom remade of `Clock`, provides a callback to disconnect
]]
function HarukaLib.Clock(tickTime: number, func: () -> ())
	local nowTime = 0
	local dropTime = tickTime * 10

	local connection = RS.Heartbeat:Connect(function(deltaTime)
		nowTime += deltaTime

		if nowTime > dropTime then
			nowTime = 0
			func()

		elseif nowTime > tickTime then
			nowTime -= tickTime

			func()
		end
	end)

	return function ()
		connection:Disconnect()
	end
end

return HarukaLib
