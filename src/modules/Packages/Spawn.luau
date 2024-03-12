--!nocheck

local FreeThread: thread? = nil

local yield, create, resume = coroutine.yield, coroutine.create, coroutine.resume
local spawn = task.spawn

local function FunctionPasser(Callback, ...)
	local AquiredThread = FreeThread
	FreeThread = nil

	Callback(...)
	FreeThread = AquiredThread
end

local function Yielder()
	while true do
		FunctionPasser(yield())
	end
end

return function<T...>(Callback: (T...) -> (), ...: T...)
	if not FreeThread then
		FreeThread = create(Yielder)

		resume(FreeThread :: any)
	end

	spawn(FreeThread :: thread, Callback, ...)
end
