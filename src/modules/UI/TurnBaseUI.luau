--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Pinia = require(RepS.Modules.UI.Pinia.TurnBaseUIPinia)

local TurnBaseActionPanel = require(RepS.Modules.UI.Views.TurnBaseActionPanel)
local TurnBaseSideList = require(RepS.Modules.UI.Views.TurnBaseSideList)
local TurnBasePhaseShower = require(RepS.Modules.UI.Views.TurnBasePhaseShower)

local BottomProgressBar = require(RepS.Modules.UI.Components.BottomProgressBar)

local Children, New, Tween, Computed = Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed

local TurnBaseUI = {}
TurnBaseUI.__index = TurnBaseUI
TurnBaseUI.__type = "TurnBaseUI"

local v2New = Vector2.new
local fromScale = UDim2.fromScale
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
	HarukaLib:Hydrate(self.char, {
		["Attr-InCombat"] = function(newState: boolean)
			charStatsDict.isInCombat:set(newState)
		end,
		["Attr-TP"] = function(newTP: number)
			charStatsDict.TP:set(newTP)
		end
	})

	local scope = self.scope
    Components.ScreenGui(scope, {
        Name = "TurnBasedUI",
		DisplayOrder = 5,
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame(scope, {
				Name = "BG",
				AnchorPoint = v2New(0.5, 0.9),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				Visible = Computed(scope, function(use)
					return use(charStatsDict.isInCombat)
				end),
				Position = Tween(scope, Computed(scope, function(use)
					return if use(charStatsDict.isInCombat) then fromScale(0.5, 1) else fromScale(0.5, 1.5)
				end), AssetBook.TweenInfos.twiceHalfOne),

                [Children] = {
                    New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.146 }),

                    TurnBaseActionPanel(self),

					TurnBaseSideList("Monster", self),
					TurnBaseSideList("Player", self),

					Components.TextLabel(scope, {
						Name = "BottomTip",
						AnchorPoint = v2New(0.5, 0.5),
						Position = fromScale(0.5, -0.7),
						Size = fromScale(1, 0.5),

						Text = Computed(scope, function(use)
							return use(self.bottomTipText)
						end),

						[Children] = {
							Components.TextUIStroke(scope, { Thickness = 2.5 }),
							New(scope, "UITextSizeConstraint")({ MaxTextSize = 28 })
						}
					}),

					BottomProgressBar("PhaseTimer", self)
                }
            }),
			Components.Frame(scope, {
				Name = "CenterBG",

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					TurnBasePhaseShower(self)
				}
			})
        }
    })

	local function onDead()
		Events.NewPhase:DisconnectAll()

		Fusion.doCleanup(scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(onDead)
end