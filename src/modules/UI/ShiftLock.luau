--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local isMobile = HarukaLib:GetDevice() == "Mobile"

local MobileShiftLock = {}
MobileShiftLock.__index = MobileShiftLock
MobileShiftLock.__type = "MobileShiftLock"

local cfNew, cfAngle = CFrame.new, CFrame.Angles
local v2New = Vector2.new
local fromScale = UDim2.fromScale


function MobileShiftLock:SetLockState(state: string)
	if state == "On" then
		self.enabled = true
		self.icon:set(self.ON_ICON)
	else
		self.enabled = false
		self.icon:set(self.OFF_ICON)
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
					local _, y, _ = camera.CFrame:ToOrientation()
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
	local scope = Fusion.scoped({})

	self.char = plr.Character or plr.CharacterAdded:Wait()

	self.rsConnection, self.enabled = nil, false
	self.ON_ICON, self.OFF_ICON = "rbxasset://textures/ui/mouseLock_on.png", "rbxasset://textures/ui/mouseLock_off.png"

	self.icon = Fusion.Value(scope, self.OFF_ICON)

	Fusion.New(scope, "ScreenGui")({
		Name = "MobileShiftLock",
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		DisplayOrder = 10,
		Parent = plr:FindFirstChildOfClass("PlayerGui"),

		[Fusion.Children] = {
			Components.Frame(scope, {
				AnchorPoint = v2New(1, 0.5),
				ZIndex = 999,
				Position = fromScale(0.984, 0.6),
				Size = fromScale(0.035, 0.085),

				[Fusion.Children] = {
					Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 1.007 }),

					Components.HoverImageButton(scope, {
						Image = Fusion.Computed(scope, function(use)
							return use(self.icon)
						end),

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

		Fusion.doCleanup(scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(clearGarbage)
end
