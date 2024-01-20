--!nocheck

local Spawn = require(script.Parent.Parent["red-blox_spawn"].spawn)

type SignalNode<T...> = {
	Next: SignalNode<T...>?,
	Callback: (T...) -> (),
}

export type Signal<T...> = {
	Root: SignalNode<T...>?,

	Connect: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Wait: (self: Signal<T...>) -> T...,
	Once: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

-- Extracted this function from Connect as it results in the closure
-- made in Connect using less memory because this function can be static
local function Disconnect<T...>(self: Signal<T...>, Node: SignalNode<T...>)
	if self.Root == Node then
		self.Root = Node.Next
	else
		local Current = self.Root

		while Current do
			if Current.Next == Node then
				Current.Next = Node.Next
				break
			end

			Current = Current.Next
		end
	end
end

--[[
	This will connect the listener to the Signal and return a function
	that can be used to disconnect the listener from the signal.

	Listeners are passed all values fired.
]]
function Signal.Connect<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
	local Node = {
		Next = self.Root,
		Callback = Callback,
	}

	self.Root = Node

	return function()
		Disconnect(self, Node)
	end
end

--[[
	This method yields until the next time the Signal is fired, and returns all values fired.
]]
function Signal.Wait<T...>(self: Signal<T...>): T...
	local Thread = coroutine.running()
	local Disconnect

	Disconnect = self:Connect(function(...)
		Disconnect()
		coroutine.resume(Thread, ...)
	end)

	return coroutine.yield()
end

--[[
	Similar to Connect, with the difference being that the listener
	provided will only run once when the signal is fired.
]]
function Signal.Once<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
	local Disconnect

	Disconnect = self:Connect(function(...)
		Disconnect()
		Callback(...)
	end)

	return Disconnect
end

--[[
	This will fire the passed values to all connected listeners.
]]
function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
	local Current = self.Root

	while Current do
		Spawn(Current.Callback, ...)
		Current = Current.Next
	end
end

--[[
	Disconnects all listeners from the Signal, enabling it to be garbage collected
]]
function Signal.DisconnectAll<T...>(self: Signal<T...>)
	self.Root = nil
end

return function<T...>(): Signal<T...>
	return setmetatable({
		Root = nil,
	}, Signal) :: any
end
