--!strict

local RunService = game:GetService("RunService")

if RunService:IsServer() then
	if not script:FindFirstChild("Reliable") then
		Instance.new("RemoteEvent", script).Name = "Reliable"
	end
	if not script:FindFirstChild("Unreliable") then
		Instance.new("UnreliableRemoteEvent", script).Name = "Unreliable"
	end

elseif not script:FindFirstChild("Reliable") or not script:FindFirstChild("Unreliable") then
	repeat task.wait() until script:FindFirstChild("Reliable") and script:FindFirstChild("Unreliable")
end

return {
	Reliable = script.Reliable,
	Unreliable = script.Unreliable,
}