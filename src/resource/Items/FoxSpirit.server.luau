--!strict

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Events = require(game:GetService("ServerScriptService").Modules.Data.ServerEvents)

local char = script.Parent.Parent.Parent :: Model

local wait = task.wait
local cfNew, cfFromEulerAnglesXYZ = CFrame.new, CFrame.fromEulerAnglesXYZ
local insert = table.insert

while wait(1) do
	if not char.PrimaryPart then break end

	local uri = RepS.Package.MagicAssets.UriClone:Clone() :: Model
	uri.PrimaryPart.CFrame = char.PrimaryPart.CFrame
	uri.Parent = char
	Debris:AddItem(uri, 1)

    local parts = {}
	for _, child in pairs(uri:GetChildren()) do
		if child:IsA("UnionOperation") and char:FindFirstChild(child.Name) then
			child.CFrame = char[child.Name].CFrame
			child.Transparency = 0
			if child.Name == "Head" then
				child.CFrame = char.Head.CFrame * cfNew(0,0.75,0)
				child.CFrame = char.Head.CFrame * cfFromEulerAnglesXYZ(0,90,0)
			end

            insert(parts, child)
		end
	end
    Events.ClientTween:Fires(parts, { Transparency = 1 }, "twiceHalfOne")
end
