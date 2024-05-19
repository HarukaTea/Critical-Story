--!nocheck

local Debris = game:GetService("Debris")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local model = script.Parent :: Model
local char = model.Owner.Value :: Model

local wait = task.wait
local v3New = Vector3.new
local cfNew = CFrame.new

pcall(function()
	Debris:AddItem(model, 1)

	wait(0.5)
	for i = 1, 2 do
		for _, child: BasePart in model:GetChildren() do
			if child.Name == "Position"..i then
				local post = ServerUtil:FindPartOnRay(child.Position + v3New(0, 10, 0))

				local blast = model.Projectile.Value:Clone() :: Model
				blast.Owner.Value = model.Owner.Value
				blast:PivotTo(cfNew(post, post + child.CFrame.LookVector))
				blast.Parent = char.AttackHolder.Value

				for _, descendant: BasePart in blast:GetDescendants() do
					if descendant:IsA("BasePart") then descendant.Color = model:GetAttribute("SlimeColor") end
				end
				Debris:AddItem(blast, 10)

				child:Destroy()
			end
		end
		wait(0.1)
	end
end)
