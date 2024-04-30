--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ActionPanel = require(RepS.Modules.UI.Views.ActionPanel)
local MobPhase = require(RepS.Modules.UI.Views.MobPhase)
local PlayerPhase = require(RepS.Modules.UI.Views.PlayerPhase)
local PhaseShower = require(RepS.Modules.UI.Views.PhaseShower)
local TurnBaseTimer = require(RepS.Modules.UI.Views.TurnBaseTimer)

local TurnBaseStatBar = require(RepS.Modules.UI.Components.TurnBaseStatBar)

local Children, New, Tween, Computed, Value, AttributeChange =
	Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed, Fusion.Value, Fusion.AttributeChange

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew, ud2New = UDim.new, UDim2.new
local fromRGB = Color3.fromRGB
local wait = task.wait

return function (plr: Player)
    local self = setmetatable({}, TurnBaseUI)

    self.plr = plr
	self.char = plr.Character or plr.CharacterAdded:Wait()
	self.charData = self.char:WaitForChild("CharStats", 999)

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	self.isInCombat = Value(self.char:GetAttribute("InCombat"))

	self.transHPBarSize = Value(fromScale(0, 0.875))

	self.attackingTimeBar = Value(fromScale(1, 1))
	self.attackingTimeTweenInfo = Value(AssetBook.TweenInfos.fourHalf)

	local char = self.char
	self.charStatsDict = {
		Shield = Value(char:GetAttribute("Shield")),
		MaxShield = Value(char:GetAttribute("MaxShield")),
		TP = Value(char:GetAttribute("TP"))
	}
	Fusion.Hydrate(self.char)({
		[AttributeChange("InCombat")] = function(newState: boolean)
			self.isInCombat:set(newState)
		end,
		[AttributeChange("OrbAttackingTime")] = function(newState: boolean)
			self.attackingTimeTweenInfo:set(if newState then AssetBook.TweenInfos.fifteen else AssetBook.TweenInfos.fourHalf)
			self.attackingTimeBar:set(if newState then fromScale(0, 1) else fromScale(1, 1))
		end,
		[AttributeChange("Shield")] = function(newShield: number)
			self.charStatsDict.Shield:set(newShield)
		end,
		[AttributeChange("MaxShield")] = function(newShield: number)
			self.charStatsDict.MaxShield:set(newShield)
		end,
		[AttributeChange("TP")] = function(newTP: number)
			self.charStatsDict.TP:set(newTP)
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

                    ActionPanel(self),
                    MobPhase(self),
                    PlayerPhase(self),

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
					New("Frame")({
						Name = "MobAttackingTimeBar",
						BackgroundColor3 = fromRGB(30, 30, 30),
						Position = fromScale(0, 0.8),
						Size = fromScale(1, 0.1),
						ZIndex = 2,

						Visible = Computed(function(use)
							return use(self.attackingTimeTweenInfo).Time == 15
						end),

						[Children] = {
							New("Frame")({
								Name = "Bar",
								BackgroundTransparency = 0.4,

								Size = Tween(Computed(function(use)
									return use(self.attackingTimeBar)
								end), self.attackingTimeTweenInfo)
							})
						}
					}),
                }
            }),
			Components.Frame({
				Name = "CenterBG",

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					PhaseShower(self)
				}
			}),
			Components.Frame({
				Name = "TopBG",
				AnchorPoint = v2New(0.5, 0),
				Position = ud2New(0.5, 0, 0, 58),
				Size = fromScale(1, 0.1),

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					TurnBaseTimer(self)
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