--!nocheck

local CS = game:GetService("CollectionService")
local RS = game:GetService("RunService")

local PostStroke = {}
PostStroke.__index = PostStroke

local clock = os.clock
local v2New = Vector2.new

local DESIGN_VP_SIZE = v2New(1208, 470)

local function _calScreenRatio() : number
	local function average(vector2: Vector2) : number
		return (vector2.X + vector2.Y) / 2
	end

	return average(workspace.CurrentCamera.ViewportSize) / average(DESIGN_VP_SIZE)
end

--[[
	Automatically tag all UIStrokes in PlayerGui
]]
function PostStroke:FindAndGiveTag()
	for _, element in self.plrGui:GetDescendants() do
		if element:IsA("UIStroke") then
			CS:AddTag(element, "ScreenStroke")
		end
	end

	self.plrGui.DescendantAdded:Connect(function(added)
		if added:IsA("UIStroke") then
			CS:AddTag(added, "ScreenStroke")
		end
	end)
end

--[[
	Update the tagged UIStrokes every 0.5 seconds
]]
function PostStroke:UpdateStroke()
	local fpsLimit, lastTick = 0.5, 0

	RS.Heartbeat:Connect(function()
		if clock() - lastTick >= fpsLimit then
			lastTick = clock()

			for i, thickness in self.uiStrokes do
				if not i.Parent then
					self.uiStrokes[i] = nil
				else
					i.Thickness = thickness * _calScreenRatio()
				end
			end
		end
	end)
end

return function(plr: Player)
	local self = setmetatable({}, PostStroke)

	self.plrGui = plr.PlayerGui
	self.uiStrokes = {}

	CS:GetInstanceAddedSignal("ScreenStroke"):Connect(function(added: Instance)
		self.uiStrokes[added] = added.Thickness
		added.Thickness *= _calScreenRatio()
	end)

	self:FindAndGiveTag()
	self:UpdateStroke()
end
