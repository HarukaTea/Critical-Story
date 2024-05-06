--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local Components = require(RepS.Modules.UI.Vanilla)
local DeviceGetter = require(RepS.Modules.Packages.DeviceGetter)
local Fusion = require(RepS.Modules.Packages.Fusion)

local isMobile = DeviceGetter:IsPhone() or DeviceGetter:IsTablet()

local MobileShiftLock = {}
MobileShiftLock.__index = MobileShiftLock
MobileShiftLock.__type = "MobileShiftLock"

local cfNew, cfAngle = CFrame.new, CFrame.Angles
local v2New = Vector2.new
local fromScale = UDim2.fromScale


function MobileShiftLock:SetLockState(state: string)
	if state == "On" then
		self.enabled = true
		Fusion.peek(self.shiftLockLabel).Image = self.ON_ICON
	else
		self.enabled = false
		Fusion.peek(self.shiftLockLabel).Image = self.OFF_ICON
	end
end

function MobileShiftLock:EnableShiftLock()
	if self.enabled then
		--- store variables to reduce index time spent in RenderStepped
		local camera = workspace.CurrentCamera

		self.rsConnection = RS.RenderStepped:Connect(function()
			self.char.Humanoid.AutoRotate = not self.enabled

			if self.enabled then
				if not self.char.Humanoid.Sit then
					local x, y, z = camera.CFrame:ToOrientation()
					self.char.PrimaryPart.CFrame = cfNew(self.char.PrimaryPart.Position) * cfAngle(0, y, 0)
				end
			end

			if not self.enabled then
				if self.rsConnection then self.rsConnection:Disconnect() end
			end
		end)
	end
end

return function(plr: Player)
	if not isMobile then return end

	local self = setmetatable({}, MobileShiftLock)

	self.char = plr.Character or plr.CharacterAdded:Wait()

	self.rsConnection, self.enabled = nil, false
	self.shiftLockLabel = Fusion.Value()
	self.ON_ICON, self.OFF_ICON = "rbxasset://textures/ui/mouseLock_on.png", "rbxasset://textures/ui/mouseLock_off.png"

	local UI = Fusion.New("ScreenGui")({
		Name = "MobileShiftLock",
		ScreenInsets = Enum.ScreenInsets.None,
		DisplayOrder = 10,
		Parent = plr.PlayerGui,

		[Fusion.Children] = {
			Components.Frame({
				AnchorPoint = v2New(1, 0.5),
				ZIndex = 999,
				Position = fromScale(0.984, 0.6),
				Size = fromScale(0.035, 0.085),

				[Fusion.Children] = {
					Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 1.007 }),
					Components.HoverImageButton({
						Image = self.OFF_ICON,
						[Fusion.Ref] = self.shiftLockLabel,

						[Fusion.OnEvent("MouseButton1Click")] = function()
							if self.char:FindFirstChild("Humanoid") and self.char.PrimaryPart then
								self:SetLockState(if self.enabled then "Off" else "On")
								self:EnableShiftLock()
							end
						end,
					}),
				},
			}),
		},
	})

	--- listening events
	local function clearGarbage()
		self:SetLockState("Off")

		UI:Destroy()

		self = nil
	end
	self.char.Humanoid.Died:Once(clearGarbage)
end
