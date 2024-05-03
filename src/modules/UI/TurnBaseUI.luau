--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Pinia = require(RepS.Modules.UI.Pinia.TurnBaseUIPinia)

local TurnBaseActionPanel = require(RepS.Modules.UI.Views.TurnBaseActionPanel)
local TurnBaseSideList = require(RepS.Modules.UI.Views.TurnBaseSideList)
local TurnBasePhaseShower = require(RepS.Modules.UI.Views.TurnBasePhaseShower)

local BottomProgressBar = require(RepS.Modules.UI.Components.BottomProgressBar)
local TurnBaseStatBar = require(RepS.Modules.UI.Components.TurnBaseStatBar)

local Children, New, Tween, Computed, AttributeChange =
	Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed, Fusion.AttributeChange

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI
TurnBaseUI.__type = "TurnBaseUI"

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local wait = task.wait

return function (plr: Player)
    local self = setmetatable({}, TurnBaseUI)

    self.plr = plr
	self.char = plr.Character or plr.CharacterAdded:Wait()
	self.charData = self.char:WaitForChild("CharStats", 999)

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local charStatsDict = self.charStatsDict :: table
	Fusion.Hydrate(self.char)({
		[AttributeChange("InCombat")] = function(newState: boolean)
			self.isInCombat:set(newState)
		end,
		[AttributeChange("Shield")] = function(newShield: number)
			charStatsDict.Shield:set(newShield)
		end,
		[AttributeChange("MaxShield")] = function(newShield: number)
			charStatsDict.MaxShield:set(newShield)
		end,
		[AttributeChange("TP")] = function(newTP: number)
			charStatsDict.TP:set(newTP)
		end
	})

    local UI = Components.ScreenGui({
        Name = "TurnBasedUI",
		DisplayOrder = 5,
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame({
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				Visible = Computed(function(use)
					return use(self.isInCombat)
				end),
				Position = Tween(Computed(function(use)
					return if use(self.isInCombat) then fromScale(0.5, 1) else fromScale(0.5, 1.5)
				end), AssetBook.TweenInfos.twiceHalfOne),

                [Children] = {
                    New("UIAspectRatioConstraint")({ AspectRatio = 25.146 }),

                    TurnBaseActionPanel(self),

					TurnBaseSideList("Monster", self),
					TurnBaseSideList("Player", self),

                    Components.Frame({
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.42),
						ZIndex = 2,

						[Children] = {
							New("UIListLayout")({
								Padding = udNew(0.01, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							TurnBaseStatBar("DEF", self),
							Components.Frame({
								Name = "TransBar",

								Size = Tween(Computed(function(use)
									return use(self.transHPBarSize)
								end), AssetBook.TweenInfos.half),
							}),
							TurnBaseStatBar("TP", self)
						},
					}),

					BottomProgressBar("PhaseTimer", self)
                }
            }),
			Components.Frame({
				Name = "CenterBG",

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					TurnBasePhaseShower(self)
				}
			})
        }
    })

	local function onDead()
		UI:Destroy()

		Events.NewPhase:DisconnectAll()
	end
	self.char.Humanoid.Died:Once(onDead)
end