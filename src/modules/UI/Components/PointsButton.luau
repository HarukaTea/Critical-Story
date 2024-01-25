--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed, peek = Fusion.Children, Fusion.New, Fusion.Computed, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local upper = string.upper

local COLORS = {
	DMG = fromRGB(255, 0, 0),
	Health = fromRGB(85, 255, 0),
	Mana = fromRGB(0, 255, 255),
	Shield = fromRGB(255, 255, 0),
	Magic = fromRGB(170, 170, 255),
}
local POS = {
	DMG = fromScale(0.721, 0.732),
	Health = fromScale(0.669, 0.322),
	Mana = fromScale(0.162, 0.125),
	Shield = fromScale(0.162, 0.847),
	Magic = fromScale(0.106, 0.556),
}
local POINTS = {
	DMG = "DmgPoints",
	Health = "HealthPoints",
	Mana = "ManaPoints",
	Shield = "ShieldPoints",
	Magic = "MagicPoints"
}

local function AddButtonChildren(id: string) : table
	return {
		New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
		Components.UIStroke({
			Transparency = 0.2,
			Color = COLORS[id],
			Thickness = 2.5,
			Enabled = true,
		}),
	}
end
local function PointsButton(id: string, direction: string, self: table): Frame
	return New("Frame")({
        Name = id,
		BackgroundTransparency = 1,
		Position = POS[id],
		Size = fromScale(0.177, 0.1),

		[Children] = {
			Components.TextLabel({
				Name = "Stat",
				Size = fromScale(1, 1),
				FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
				TextXAlignment = if direction == "Left" then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
				TextColor3 = COLORS[id],
                Text = Computed(function(use)
					return upper(id)..": "..use(self.playerData[id]).." ("..use(self.charData[id])..")"
				end)
			}),
			Components.TextButton({
				Name = "Add",
				Size = fromScale(0.15, 1),
				Position = if direction == "Left" then fromScale(-0.195, 0) else fromScale(1.05, 0),
				Text = "+",
				Visible = Computed(function(use)
					return if use(self.playerData.LvPoints) > 0 then true else false
				end),

				[Fusion.OnEvent("MouseButton1Click")] = function()
					if peek(self.playerData.LvPoints) > 0 then
						workspace.Sounds.SFXs.Ding:Play()

						Events.AddPoints:Fire(POINTS[id], 1)
					else
						Signals.CreateHint:Fire("You don't have enough skill points!")
					end
				end,

				[Children] = AddButtonChildren(id)
			}),
			Components.TextButton({
				Name = "Add10",
				Size = fromScale(0.28, 1),
				Position = if direction == "Left" then fromScale(-0.565, 0) else fromScale(1.29, 0),
				Text = "+10",
				Visible = Computed(function(use)
					return if use(self.playerData.LvPoints) >= 10 then true else false
				end),

				[Fusion.OnEvent("MouseButton1Click")] = function()
					if peek(self.playerData.LvPoints) >= 10 then
						workspace.Sounds.SFXs.Ding:Play()

						Events.AddPoints:Fire(POINTS[id], 10)
					else
						Signals.CreateHint:Fire("You don't have enough skill points!")
					end
				end,

				[Children] = AddButtonChildren(id)
			})
		},
	})
end

return PointsButton
