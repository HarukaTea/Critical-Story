--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

--- Handles initial preparation of the game server-side.
return function (cmdr)
	local ReplicatedRoot, RemoteFunction, RemoteEvent

	local function Create(class, name, parent)
		local object = Instance.new(class)
		object.Name = name
		object.Parent = parent or ReplicatedRoot

		return object
	end

	ReplicatedRoot = script.Parent.CmdrClient
	ReplicatedRoot.Parent = RepS

	RemoteFunction = Create("RemoteFunction", "CmdrFunction")
	RemoteEvent = Create("RemoteEvent", "CmdrEvent")

	Create("Folder", "Commands")
	Create("Folder", "Types")

	script.Parent.Shared.Parent = ReplicatedRoot

	cmdr.ReplicatedRoot = ReplicatedRoot
	cmdr.RemoteFunction = RemoteFunction
	cmdr.RemoteEvent = RemoteEvent

	cmdr:RegisterTypesIn(script.Parent.BuiltInTypes)

	script.Parent.BuiltInTypes:Destroy()
	script.Parent.BuiltInCommands.Name = "Server commands"
end
