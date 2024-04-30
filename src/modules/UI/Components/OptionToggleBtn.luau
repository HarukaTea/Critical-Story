--!nocheck
--!optimize 2
--!native

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

local function OptionToggleBtn(id: string, self: table) : Frame
	local TEXTS = {
		Musics = "Musics",
		SFXs = "Sound Effects",
		PublicCombat = "Public Combat Mode",
		PotatoMode = "Low Detail Mode",
		PlayerList = "Player List",
	}
    local isSelecting = Fusion.Value(false)

    return Components.Frame({
		Name = id,

		[Children] = {
			Components.TextLabel({
				Name = "Title",
				Size = fromScale(0.65, 1),
				Text = TEXTS[id],
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			Components.HoverImageButton({
				Name = "SwitchBG",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Position = fromScale(0.7, 0),
				Size = fromScale(0.2, 1),

				[OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
				[OnEvent("MouseButton1Click")] = function()
					local plr = self.plr :: Player

                    workspace.Sounds.SFXs[if Fusion.peek(self.playerSettings[id]) then "SwitchOff" else "SwitchOn"]:Play()

					Events.ChangePlayerSetting:Fire(id)

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
					Components.RoundUICorner(),
					Components.UIStroke({
						Thickness = 3,
						Enabled = true,

						Transparency = Tween(Computed(function(use)
							return if use(isSelecting) then 0.3 else 1
						end), AssetBook.TweenInfos.twiceHalf)
					})
				}
			}),
			Components.Frame({
				Name = "Switch",
				BackgroundTransparency = 0,
				AnchorPoint = v2New(),
				Size = fromScale(0.1, 1),

				BackgroundColor3 = Tween(Computed(function(use)
					return if use(self.playerSettings[id]) then fromRGB(80, 161, 118) else fromRGB(214, 71, 107)
				end), AssetBook.TweenInfos.threeHalf),
				Position = Tween(Computed(function(use)
					return if use(self.playerSettings[id]) then fromScale(0.8, 0) else fromScale(0.7, 0)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = { Components.RoundUICorner() }
			})
		}
	})
end

return OptionToggleBtn
