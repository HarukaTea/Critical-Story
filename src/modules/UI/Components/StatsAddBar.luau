--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children, Computed, peek = Fusion.Children, Fusion.Computed, Fusion.peek

local udNew =  UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

local barColorIds = {
	Levels = fromRGB(255, 255, 0),
	Health = fromRGB(85, 255, 127),
	DMG = fromRGB(255, 85, 0),
	Magic = fromRGB(170, 170, 255),
	Mana = fromRGB(85, 255, 255),
	CriChance = fromRGB(255, 255, 0),
	CriDMG = fromRGB(255, 255, 0),
	Shield = fromRGB(255, 170, 0),
	PSV = fromRGB(255, 255, 255),
	SkillPoints = fromRGB(255, 255, 0),
	ResetCost = fromRGB(255, 85, 127),
}

local function StatsPadding(self: table) : UIPadding
	local scope = self.scope :: Fusion.Scope

	return Fusion.New(scope, "UIPadding")({
		PaddingBottom = udNew(0.1, 0),
		PaddingLeft = udNew(0.05, 0),
		PaddingRight = udNew(0.05, 0),
		PaddingTop = udNew(0.1, 0)
	})
end
local function StatsGradient(self: table) : UIGradient
	local scope = self.scope :: Fusion.Scope

	return Fusion.New(scope, "UIGradient")({
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
end
local function StatsAddBar(id: string, self: table, title: string, order: number)
	local scope = self.scope :: Fusion.Scope

	local isSelecting = Fusion.Value(scope, false)
	local isSelecting2 = Fusion.Value(scope, false)
	local clickCooldown = false

	local children: TextButton
	if id ~= "ResetCost" then
		children = Components.TextButton(scope, {
			Name = "Add5",
			Position = fromScale(0.9, 0),
			Size = fromScale(0.1, 1),
			Text = "+5",
			AutoButtonColor = false,

			TextColor3 = Computed(scope, function(use: Fusion.Use)
				return if use(isSelecting2) then fromRGB() else barColorIds[id]
			end),
			BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
				return if use(isSelecting2) then fromRGB(255, 255, 255) else fromRGB()
			end),

			[Fusion.OnEvent("MouseEnter")] = function()
				isSelecting2:set(true)
			end,
			[Fusion.OnEvent("MouseLeave")] = function()
				isSelecting2:set(false)
			end,
			[Fusion.OnEvent("MouseButton1Click")] = function()
				if clickCooldown then return end

				clickCooldown = true
				Spawn(function()
					task.wait(0.1)
					clickCooldown = false
				end)

				if peek(self.playerData.LvPoints) < 5 then
					Signals.CreateHint:Fire("You don't have enough skill points!")
					return
				end

				workspace.Sounds.SFXs.Ding:Play()
				Events.AddPoints.Fire({ Target = id.."Points", Points = 5 })
			end,

			[Children] = {
				Fusion.New(scope, "UICorner")({
					CornerRadius = UDim.new(0.1, 0)
				}),
				Components.UIStroke(scope, {
					Thickness = 3,
					Enabled = true,

					Color = Computed(scope, function(use: Fusion.Use)
						return if use(isSelecting2) then fromRGB() else barColorIds[id]
					end)
				})
			}
		})
	end

	return Components.Frame(scope, {
		Name = id,
		BackgroundTransparency = 0,
		Size = fromScale(1, 0.08),
		LayoutOrder = order,

		[Children] = {
			Components.RoundUICorner(scope),

			StatsGradient(self),

			Components.TextLabel(scope, {
				Name = "Stats",
				Size = fromScale(0.77, 1),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(scope, function(use: Fusion.Use)
					if id == "PSV" then
						return "NONE" --// TODO: Implement PSV

					elseif id == "ResetCost" then
						local cost = ((use(self.playerData.Levels) - 1) * Formula.LevelPerPoint
						- use(self.playerData.LvPoints)) * Formula.PointsResetCost

						return HarukaLib:NumberConvert(cost, "%.1f")

					else
						if id == "DMG" then
							local minDMG, maxDMG = use(self.charData.MinDMG) :: number, use(self.charData.MaxDMG) :: number

							return use(self.playerData[id]).." ("..if minDMG >= maxDMG then maxDMG else minDMG.."-"..maxDMG..")"
						else
							return use(self.playerData[id]).." ("..use(self.charData[id])..")"
						end
					end
				end),

				[Children] = { StatsPadding(self) }
			}),
			Components.TextLabel(scope, {
				Name = "Title",
				Size = fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = barColorIds[id],
				Text = title,

				[Children] = { StatsPadding(self) }
			}),
			Components.TextButton(scope, {
				Name = "Add",
				Position = fromScale(0.78, 0),
				Size = fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				FontFace = if id == "ResetCost" then
					Font.fromEnum(Enum.Font.SourceSansBold) else Font.fromEnum(Enum.Font.GothamBold),
				Text = if id == "ResetCost" then "X" else "+",
				AutoButtonColor = false,

				TextColor3 = Computed(scope, function(use: Fusion.Use)
					return if use(isSelecting) then fromRGB() else barColorIds[id]
				end),
				BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
					return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB()
				end),

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[Fusion.OnEvent("MouseButton1Click")] = function()
					if clickCooldown then return end

					clickCooldown = true
					Spawn(function()
						task.wait(0.1)
						clickCooldown = false
					end)
					if id == "ResetCost" then
						local cost = ((peek(self.playerData.Levels) - 1) * Formula.LevelPerPoint
						- peek(self.playerData.LvPoints)) * Formula.PointsResetCost

						if cost <= 0 then return end --- fix event dupe

						Events.AddPoints.Fire({ Target = "Reset" })
						return
					end

					if peek(self.playerData.LvPoints) < 1 then
						Signals.CreateHint:Fire("You don't have enough skill points!")
						return
					end

					workspace.Sounds.SFXs.Ding:Play()
					Events.AddPoints.Fire({ Target = id.."Points", Points = 1 })
				end,

				[Children] = {
					Fusion.New(scope, "UICorner")({
						CornerRadius = UDim.new(0.1, 0)
					}),
					Components.UIStroke(scope, {
						Thickness = 2.5,
						Enabled = true,

						Color = Computed(scope, function(use: Fusion.Use)
							return if use(isSelecting) then fromRGB() else barColorIds[id]
						end)
					})
				}
			}),

			children
		}
	})
end

return StatsAddBar
