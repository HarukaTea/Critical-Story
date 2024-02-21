--!nocheck

local Debris = game:GetService("Debris")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local model = script.Parent :: Model
local char = model.Owner.Value :: Model

local wait = task.wait
local v3New = Vector3.new
local cfNew = CFrame.new

wait(0.5)
for i = 1,2 do
	for _, child in pairs(model:GetChildren()) do
		if child.Name == "Position"..i then
			local post = ServerUtil:FindPartOnRay(child.Position + v3New(0, 10, 0), { model })

			local blast = model.Projectile.Value:Clone() :: Model
			blast.Owner.Value = model.Owner.Value
			blast:PivotTo(cfNew(post, post + child.CFrame.LookVector))
			blast.Parent = char.Holder.Value

			for _, descendant in blast:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Color = model:GetAttribute("SlimeColor")
				end
			end
			Debris:AddItem(blast, 10)

			child:Destroy()
		end
	end
	wait(0.1)
end
model.Base:Destroy()

wait(1)
model:Destroy()
