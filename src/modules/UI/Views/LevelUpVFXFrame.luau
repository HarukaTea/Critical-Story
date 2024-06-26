--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local wait = task.wait

local function LevelUpVFXFrame(self: table) : Frame
    local scope = self.scope

    local function _showLvlUpVFX()
		self.levelUpShown:set(true)

		wait(0.2)
		self.levelUpPos:set(fromScale(0.42, 0))

		wait(0.6)
		self.levelUpTitleShown:set(true)

		wait(1)
		self.levelUpShown:set(false)
		self.levelUpPos:set(fromScale(0.55, 0))
		self.levelUpTitleShown:set(false)
	end
	Events.LevelUp:Connect(_showLvlUpVFX)

    return Components.Frame(scope, {
        Name = "LevelUPVFX",

        Visible = Computed(scope, function(use)
            return use(self.levelUpShown)
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "Level",
                AnchorPoint = v2New(0.5, 0),
                Size = fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 0,

                Position = Fusion.Tween(scope, Computed(scope, function(use)
                    return use(self.levelUpPos)
                end), AssetBook.TweenInfos.half),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Thickness = 3,
                        Enabled = true
                    }),
                    Components.TextLabel(scope, {
                        Name = "Stat",
                        Position = fromScale(0.5, 0.5),
                        Size = fromScale(0.7, 0.7),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        AnchorPoint = v2New(0.5, 0.5),

                        Text = Computed(scope, function(use)
                            return use(self.playerData.Levels)
                        end)
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "LevelUPTitle",
                Position = fromScale(0.468, 0.149),
                Size = fromScale(0.15, 0.615),
                Text = "LEVEL UP!",
                TextColor3 = fromRGB(255, 255, 127),
                TextXAlignment = Enum.TextXAlignment.Left,

                Visible = Computed(scope, function(use)
                    return use(self.levelUpTitleShown)
                end),

                [Children] = { Components.TextUIStroke(scope, { Thickness = 2.5 }) }
            })
        },
    })
end

return LevelUpVFXFrame
