--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

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
local function StatViewBar(id: string, self: table, title: string, order: number) : Frame
	local scope = self.scope :: Fusion.Scope

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
				Size = fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Computed(scope, function(use: Fusion.Use)
					if id == "Levels" then
						return use(self.playerData.EXP[1]).."/"..use(self.playerData.EXP[2])

					elseif id == "DMG" then
						local minDMG, maxDMG = use(self.charData.MinDMG) :: number, use(self.charData.MaxDMG) :: number

                   		return if minDMG >= maxDMG then maxDMG else minDMG.."-"..maxDMG

					elseif id == "CriChance" or id == "CriDMG" then
						return use(self.charData[id]).."%"

					elseif id == "PSV" then
						return "NONE" --// TODO: Implement PSV

					elseif id == "SkillPoints" then
						return use(self.playerData.LvPoints)

					else
						return use(self.charData[id])
					end
				end),

				[Children] = { StatsPadding(self) }
			}),
			Components.TextLabel(scope, {
				Name = "Title",
				Size = fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = barColorIds[id],

				Text = Computed(scope, function(use: Fusion.Use)
					return if id ~= "Levels" then title else "Lv."..use(self.playerData.Levels)
				end),

				[Children] = { StatsPadding(self) }
			})
		}
	})
end

return StatViewBar
