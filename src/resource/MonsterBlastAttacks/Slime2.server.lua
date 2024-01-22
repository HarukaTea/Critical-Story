--!nocheck

local ServerUtil = require(game:GetService("ServerScriptService").Modules.Utils.ServerUtil)

local model = script.Parent
local char = model.Owner.Value

local wait = task.wait
local v3New = Vector3.new
local cfNew = CFrame.new

wait(0.5)
for i = 1, 5 do
	for _, child in model:GetChildren() do
		if child.Name == "Position" .. i then
			if (child.Position - char.Parent.Position).Magnitude >= 46 then
				child:Destroy()

				model.SlimeAttack:Play()

				wait(0.5)
				model:Destroy()
				return
			end

			local post = ServerUtil:FindPartOnRay(child.Position + v3New(0, 10, 0), { model })

			local blast = model.Projectile.Value:Clone()
			blast.Owner.Value = model.Owner.Value
			blast:PivotTo(cfNew(post, post + child.CFrame.LookVector))
			blast.Parent = char.Holder.Value
			for _, descendant in blast:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Color = model:GetAttribute("SlimeColor")
				end
			end

			char.PrimaryPart.CFrame = blast.Base.CFrame * cfNew(0, char.PrimaryPart.Size.Y / 2, 0)
			child:Destroy()
		end
	end
	wait(0.01)
end

model.SlimeAttack:Play()

wait(1)
model:Destroy()
