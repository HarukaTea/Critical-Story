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

local Children, New, Tween, Computed, Value =
	Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed, Fusion.Value

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

	self.UI = Value()

	self.transHPBarSize = Value(fromScale(0.14, 0.875))
	self.attackingTimeBar = Value(fromScale(1, 1))
	self.attackingTimeTweenInfo = Value(AssetBook.TweenInfos.fourHalf)

	local isInCombat = Value(self.char:GetAttribute("InCombat"))
	Fusion.Hydrate(self.char)({
		[Fusion.AttributeChange("InCombat")] = function(newState: boolean)
			isInCombat:set(newState)
		end,
		[Fusion.AttributeChange("AttackingTime")] = function(newState: boolean)
			self.attackingTimeTweenInfo:set(if newState then AssetBook.TweenInfos.six else AssetBook.TweenInfos.fourHalf)
			self.attackingTimeBar:set(if newState then fromScale(0, 1) else fromScale(1, 1))
		end
	})

    Components.ScreenGui({
        Name = "TurnBasedUI",
		DisplayOrder = 5,
        Parent = plr.PlayerGui,
		[Fusion.Ref] = self.UI,

        [Children] = {
            Components.Frame({
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				Position = Tween(Computed(function(use)
					return if use(isInCombat) then fromScale(0.5, 1) else fromScale(0.5, 1.5)
				end), AssetBook.TweenInfos.twiceHalfOne),

                [Children] = {
                    New("UIAspectRatioConstraint")({ AspectRatio = 25.386 }),

                    ActionPanel(self),
                    MobPhase(self),
                    PlayerPhase(self),

                    Components.Frame({
						Name = "StatsFrame",
						AnchorPoint = v2New(0.5, 0),
						Position = fromScale(0.5, 0.15),
						Size = fromScale(1, 0.42),

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
						Name = "AttackingTimeBar",
						BackgroundColor3 = fromRGB(30, 30, 30),
						Position = fromScale(0, 0.8),
						Size = fromScale(1, 0.1),

						Visible = Computed(function(use)
							return use(self.attackingTimeTweenInfo).Time == 6
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
					Components.TextLabel({
						Name = "AttackTip",
						Position = fromScale(0, -1.2),
						Size = fromScale(1, 0.5),
						RichText = true,
						TextStrokeTransparency = 0,
						Text = [[- Touch <font color="#e74c3c">orb</font> to attack enemy! -]],

						Visible = Computed(function(use)
							return use(self.attackingTimeTweenInfo).Time == 6
						end),

						[Children] = {
							New("UITextSizeConstraint")({ MaxTextSize = 29 })
						}
					})
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


	--// Connections
	local function onDead()
		Fusion.peek(self.UI):Destroy()

		Events.NewPhase:DisconnectAll()
	end
	self.char.Humanoid.Died:Once(onDead)
end