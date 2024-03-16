--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, Value = Fusion.Children, Fusion.Value

local ud2New = UDim2.new
local fromOffset, fromScale = UDim2.fromOffset, UDim2.fromScale
local v2New = Vector2.new
local wait = task.wait

return function (plr: Player)
    local bgPos = Value(fromScale(1.7, 1.7))
	local isSwitching = Value(false)

	local char = plr.Character or plr.CharacterAdded:Wait()

	local function createBackendFrame(props: table)
		local defaultProps = {
			BackgroundColor3 = Color3.fromRGB(),
			ZIndex = 20,
		}
		for i, v in pairs(props) do defaultProps[i] = v end

		return Fusion.New("Frame")(defaultProps)
	end
	local UI = Components.ScreenGui({
		Name = "SwitchScene",
		DisplayOrder = 100,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.ImageLabel({
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.5),
				ZIndex = 20,
				Image = "rbxassetid://12209511296",
				SizeConstraint = Enum.SizeConstraint.RelativeXX,

				Size = Fusion.Tween(Fusion.Computed(function(use)
                    return use(bgPos)
                end), AssetBook.TweenInfos.half),
				Visible = Fusion.Computed(function(use)
					return use(isSwitching)
				end),

				[Children] = {
					createBackendFrame({
						Position = fromOffset(-2, -4998),
						Size = ud2New(1, 4, 0, 5000),
					}),
					createBackendFrame({
						Position = fromOffset(-4998, -4998),
						Size = fromOffset(5000, 5000),
					}),
					createBackendFrame({
						Position = fromOffset(-4998, -2),
						Size = ud2New(0, 5000, 1, 4),
					}),
					createBackendFrame({
						Position = ud2New(0, -2, 1, -2),
						Size = ud2New(1, 4, 0, 5000),
					}),
					createBackendFrame({
						Position = ud2New(1, -2, 0, -2),
						Size = ud2New(0, 5000, 1, 4),
					}),
					createBackendFrame({
						Position = ud2New(1, -2, 0, -4998),
						Size = fromOffset(5000, 5000),
					}),
					createBackendFrame({
						Position = ud2New(1, -2, 1, -2),
						Size = fromOffset(5000, 5000),
					}),
					createBackendFrame({
						Position = ud2New(0, -4998, 1, 0),
						Size = fromOffset(5000, 5000),
					}),
				},
			}),
		},
	})


    --// Connections
    local function switching(duration: number)
        if Fusion.peek(isSwitching) then return end

        isSwitching:set(true)
        bgPos:set(fromScale(0, 0))

        wait(duration)
        bgPos:set(fromScale(1.7, 1.7))

		wait(0.5)
		isSwitching:set(false)
    end
    Events.SwitchScene:Connect(switching)
    Signals.SwitchScene:Connect(switching)

	local function _onDead()
		Events.SwitchScene:DisconnectAll()
		Signals.SwitchScene:DisconnectAll()

		UI:Destroy()
	end
	char.Humanoid.Died:Once(_onDead)
end
