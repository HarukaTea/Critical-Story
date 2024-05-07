--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local ud2New = UDim2.new
local fromOffset, fromScale = UDim2.fromOffset, UDim2.fromScale
local v2New = Vector2.new
local wait = task.wait
local fromRGB = Color3.fromRGB

return function (plr: Player)
	local scope = Fusion.scoped({})
    local bgPos = Fusion.Value(scope, fromScale(1.7, 1.7))

	local char = plr.Character or plr.CharacterAdded:Wait()

	local function createBackendFrame(props: table)
		local defaultProps = {
			BackgroundColor3 = fromRGB(),
			ZIndex = 20,
		}
		for prop: string, val: any in props do defaultProps[prop] = val end

		return Fusion.New(scope, "Frame")(defaultProps)
	end
	Components.ScreenGui(scope, {
		Name = "SwitchScene",
		DisplayOrder = 100,
		Parent = plr.PlayerGui,

		[Fusion.Children] = {
			Components.ImageLabel(scope, {
				AnchorPoint = v2New(0.5, 0.5),
				Position = fromScale(0.5, 0.5),
				ZIndex = 20,
				Image = "rbxassetid://12209511296",
				SizeConstraint = Enum.SizeConstraint.RelativeXX,

				Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
                    return use(bgPos)
                end), AssetBook.TweenInfos.half),

				[Fusion.Children] = {
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
        bgPos:set(fromScale(0, 0))

        wait(duration)
        bgPos:set(fromScale(1.7, 1.7))
    end
    Events.SwitchScene:Connect(switching)
    Signals.SwitchScene:Connect(switching)

	local function _onDead()
		Events.SwitchScene:DisconnectAll()
		Signals.SwitchScene:DisconnectAll()

		Fusion.doCleanup(scope)
	end
	char.Humanoid.Died:Once(_onDead)
end
