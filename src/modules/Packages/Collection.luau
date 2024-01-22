--!nocheck

local CS = game:GetService("CollectionService")

local Spawn = require(script.Parent.Spawn)

return function(Tag: string, Start: (Instance) -> (() -> ()?))
	local InstanceMap = {}

	for _, Instance in CS:GetTagged(Tag) do
		Spawn(function()
			InstanceMap[Instance] = Start(Instance)
		end)
	end

	local AddConnection = CS:GetInstanceAddedSignal(Tag):Connect(function(Instance)
		InstanceMap[Instance] = Start(Instance)
	end)

	local RemoveConnection = CS:GetInstanceRemovedSignal(Tag):Connect(function(Instance)
		local Value = InstanceMap[Instance]

		if Value then
			InstanceMap[Instance] = nil

			Value()
		end
	end)

	return function()
		AddConnection:Disconnect()
		RemoveConnection:Disconnect()

		for _, Value in InstanceMap do
			Spawn(Value :: () -> ())
		end
	end
end
