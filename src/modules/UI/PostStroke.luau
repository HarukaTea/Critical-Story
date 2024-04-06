--!strict
--!optimize 2
--!native

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

return function(plr: Player)
	local plrGui = plr.PlayerGui
	local uiStrokes = {}
	local fpsLimit, lastTick = 0.5, 0

	--// Connections
	local function _strokeAdded(added: UIStroke)
		uiStrokes[added] = added.Thickness

		added.Thickness *= _calScreenRatio()
	end
	CS:GetInstanceAddedSignal("ScreenStroke"):Connect(_strokeAdded)

	local function _uiAdded(added: Instance)
		if added:IsA("UIStroke") then
			CS:AddTag(added, "ScreenStroke")
		end
	end
	plrGui.DescendantAdded:Connect(_uiAdded)

	local function _onHeartbeat()
		if clock() - lastTick >= fpsLimit then
			lastTick = clock()

			for i, thickness in uiStrokes do
				if not i.Parent then
					uiStrokes[i] = nil
				else
					i.Thickness = thickness * _calScreenRatio()
				end
			end
		end
	end
	RS.Heartbeat:Connect(_onHeartbeat)

	--// Setups
	for _, element in plrGui:GetDescendants() do
		if element:IsA("UIStroke") then
			CS:AddTag(element, "ScreenStroke")
		end
	end
end
