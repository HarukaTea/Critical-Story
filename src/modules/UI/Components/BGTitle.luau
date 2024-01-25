--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children = Fusion.New, Fusion.Children

local color3New, ud2New, udNew = Color3.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local ICONS = { Menu = "rbxassetid://12180639811", Backpack = "rbxassetid://2970814599" }

local function TitleFrame(id: string, self: table): Frame
	return New("Frame")({
		Name = "Top",
		BackgroundTransparency = 1,
		Size = fromScale(0.97, 0.1),
		Position = ud2New(0.01, 0, 0.04, 40),

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 25.255 }),
			Components.ImageLabel({
				Name = "Icon",
				Image = ICONS[id],
				ImageColor3 = id == "Backpack" and fromRGB(148, 148, 148) or color3New(1, 1, 1),
				Position = fromScale(0.01, 0),
				Size = fromScale(0.04, 1),
				BackgroundTransparency = 0,

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextLabel({
				Position = fromScale(0.063, 0.195),
				Size = fromScale(0.7, 0.6),
				Text = id,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			Components.TextButton({
				Position = fromScale(0.948, 0.066),
				Size = fromScale(0.04, 1),
				Text = "X",

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,
					}),
				},
				[Fusion.OnEvent("MouseButton1Click")] = function()
					local plrGui = self.plrGui :: PlayerGui

					Fusion.peek(self.UI).BG.Visible = false
					Fusion.peek(self.UI).Shadow.Visible = false

					self.plr:SetAttribute("CurrentMenu", "None")
					plrGui.AdventurerStats.BG.Visible = true
					plrGui.PlayerList.Enabled = true
					workspace.CurrentCamera.UIBlur.Enabled = false
				end,
			}),
		},
	})
end

return TitleFrame
