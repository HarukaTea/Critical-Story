--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Tween, Computed, OnEvent = Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.OnEvent

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind, sub = string.find, string.sub

local function SettingToggleBtn(id: string, self: table) : Frame
	local scope = self.scope :: Fusion.Scope
	local TEXTS = {
		Musics = "Musics",
		SFXs = "Sound Effects",
		PublicCombat = "Public Combat Mode",
		PotatoMode = "Low Detail Mode",
		PlayerList = "Player List",
		MapDetails = "Map Details",
		MapShadows = "Global Shadows",
		TreeOptimizations = "Tree Optimizations",
		HideRole = "Hide Role"
	}
    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
		Name = id,
		Size = fromScale(1, 0.08),

		[Children] = {
			Components.TextLabel(scope, {
				Name = "Title",
				Size = fromScale(0.65, 1),
				Text = TEXTS[id],
				TextXAlignment = Enum.TextXAlignment.Left,

				[Children] = {
					Fusion.New(scope, "UIPadding")({
						PaddingBottom = UDim.new(0.05, 0),
						PaddingTop = UDim.new(0.05, 0),
					})
				}
			}),
			Components.HoverImageButton(scope, {
				Name = "SwitchBG",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Position = fromScale(0.8, 0),
				Size = fromScale(0.1, 1),

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plr = self.plr :: Player

                    workspace.Sounds.SFXs[if Fusion.peek(self.playerSettings[id]) then "SwitchOff" else "SwitchOn"]:Play()

					Events.ChangePlayerSetting.Fire({ SettingId = id })

					--// combat things
					if sFind(id, "Combat") then
						local mode = sub(id, 1, sFind(id, "Combat") - 1)

						if plr:GetAttribute("CombatMode") == mode then
							plr:SetAttribute("CombatMode", "Solo")
							return
						end

						plr:SetAttribute("CombatMode", mode)
						return
					end

					--// Locally set attribute first
					plr:SetAttribute(id, not plr:GetAttribute(id))
				end,

				[Children] = {
					Components.RoundUICorner(scope),
					Components.UIStroke(scope, {
						Thickness = 3,
						Enabled = true,

						Transparency = Tween(scope, Computed(scope, function(use: Fusion.Use)
							return if use(isSelecting) then 0.3 else 1
						end), AssetBook.TweenInfos.twiceHalf)
					})
				}
			}),
			Components.Frame(scope, {
				Name = "Switch",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Size = fromScale(0.05, 1),

				BackgroundColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
					return if use(self.playerSettings[id]) then fromRGB(80, 161, 118) else fromRGB(214, 71, 107)
				end), AssetBook.TweenInfos.threeHalf),
				Position = Tween(scope, Computed(scope, function(use: Fusion.Use)
					return if use(self.playerSettings[id]) then fromScale(0.85, 0) else fromScale(0.8, 0)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = { Components.RoundUICorner(scope) }
			}),

			Components.Frame(scope, {
                Name = "BGShadows",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = fromScale(-0.02, 0.5),
                Size = fromScale(0.8, 1.2),
                BackgroundTransparency = 0,
                ZIndex = 0,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Fusion.New(scope, "UIGradient")({
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    })
                }
            }),
		}
	})
end

return SettingToggleBtn
