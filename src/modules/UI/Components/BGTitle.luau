--!strict

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, Children, OnEvent, Value, Tween, Computed =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Value, Fusion.Tween, Fusion.Computed

local color3New, ud2New, udNew = Color3.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local ICONS = { Menu = "rbxassetid://12180639811", Backpack = "rbxassetid://2970814599" }
local BG_COLOR = { Menu = Value(fromRGB(30, 30, 30)), Backpack = Value(fromRGB(30, 30, 30)) }
local CONTENT_COLOR = { Menu = Value(fromRGB(255, 255, 255)), Backpack = Value(fromRGB(255, 255, 255)) }

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
				TextColor3 = Tween(Computed(function(use)
					return use(CONTENT_COLOR[id])
				end), AssetBook.TweenInfos.twiceHalf),
				BackgroundColor3 = Tween(Computed(function(use)
					return use(BG_COLOR[id])
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,
						Color = Tween(Computed(function(use)
							return use(CONTENT_COLOR[id])
						end), AssetBook.TweenInfos.twiceHalf)
					}),
				},

				[OnEvent("MouseEnter")] = function()
					CONTENT_COLOR[id]:set(fromRGB())
					BG_COLOR[id]:set(fromRGB(255, 255, 255))
				end,
				[OnEvent("MouseLeave")] = function()
					CONTENT_COLOR[id]:set(fromRGB(255, 255, 255))
					BG_COLOR[id]:set(fromRGB())
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plrGui = self.plrGui :: PlayerGui

					Fusion.peek(self.UI).BG.Visible = false
					Fusion.peek(self.UI).Shadow.Visible = false

					self.plr:SetAttribute("CurrentMenu", "None")
					plrGui.AdventurerStats.Enabled = true
					plrGui.PlayerList.Enabled = true
					workspace.CurrentCamera.UIBlur.Enabled = false
				end,
			}),
		},
	})
end

return TitleFrame
