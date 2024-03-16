--!strict

local RunService = game:GetService("RunService")

local Type = require(script.Parent.Type)

local instanceNew = Instance.new
local wait = task.wait

if RunService:IsServer() then
	if not script:FindFirstChild("Reliable") then
		local reliableEvent = instanceNew("RemoteEvent")
		reliableEvent.Name = "Reliable"
		reliableEvent.Parent = script

	end
	if not script:FindFirstChild("Request") then
		local reliableEvent = instanceNew("RemoteEvent")
		reliableEvent.Name = "Request"
		reliableEvent.Parent = script
	end

elseif not script:FindFirstChild("Reliable") or not script:FindFirstChild("Request") then
	repeat wait() until script:FindFirstChild("Reliable") and script:FindFirstChild("Request")
end

return {
	Reliable = script.Reliable,
	Request = script.Request
} :: Type.Event
