--!strict
--!optimize 2
--!native

local Spawn = require(script.Parent.Spawn)

local insert, clear = table.insert, table.clear

type BinItem = Instance | RBXScriptConnection | () -> ...any

return function()
	local Bin: { BinItem } = {}

	return function<T>(Item: T & BinItem)
		insert(Bin, Item)

		return Item

	end, function()
		for _, Item in Bin do
			if typeof(Item) == "Instance" then
				Item:Destroy()

			elseif typeof(Item) == "RBXScriptConnection" then
				Item:Disconnect()

			elseif typeof(Item) == "function" then
				Spawn(Item)
			end
		end

		clear(Bin)
	end
end
