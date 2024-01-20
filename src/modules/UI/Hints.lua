--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Components = require(RepS.Modules.UI.Vanilla)
local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Events = HarukaFrameworkClient.Events
local Fusion = HarukaFrameworkClient.Fusion
local Signals = HarukaFrameworkClient.Signals

local Children, New, Value, Ref, peek = Fusion.Children, Fusion.New, Fusion.Value, Fusion.Ref, Fusion.peek

local Hints = {}
Hints.__index = Hints

local wait = task.wait
local v2New, ud2New, udNew = Vector2.new, UDim2.new, UDim.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset

return function(plr: Player)
	local self = setmetatable({}, Hints)

	self.hintLabel, self.hintBG = Value(), Value()

	Components.ScreenGui({
		Name = "Hints",
		DisplayOrder = 5,
		IgnoreGuiInset = false,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.Frame({
				Name = "BG",
				Position = fromScale(0.5, 0.511),
				Size = fromScale(1, 0.979),
				ZIndex = 999,
				[Ref] = self.hintBG,

				[Children] = {
					New("UIListLayout")({
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					New("UIPadding")({ PaddingTop = udNew(0, 10) }),
				},
			}),
			Components.TextButton({
				Name = "Hint",
				AnchorPoint = v2New(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				Visible = false,
				Position = ud2New(0.5, 0, 1, -85),
				Size = fromOffset(0, 30),
				Font = Enum.Font.Gotham,
				TextScaled = false,
				[Ref] = self.hintLabel,

				[Children] = {
					New("UICorner")({ CornerRadius = udNew(0.25, 0) }),
					New("UIPadding")({
						PaddingLeft = udNew(0, 11),
						PaddingRight = udNew(0, 11),
					}),
				},
			}),
		},
	})

	local function _createHint(text: string)
		local hint = peek(self.hintLabel):Clone() :: TextButton
		hint.Text = text
		hint.Parent = peek(self.hintBG)
		hint.Visible = true
		Debris:AddItem(hint, 2.2)

		workspace.Sounds.SFXs.Error:Play()
		wait(2)
		TS:Create(hint, AssetBook.TweenInfos.threeHalf, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
	end
	Events.CreateHint:Connect(_createHint)
	Signals.CreateHint:Connect(_createHint)
end
