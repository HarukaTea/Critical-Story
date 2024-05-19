--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local Hints = {}
Hints.__index = Hints
Hints.__type = "Hints"

local wait = task.wait
local v2New, udNew = Vector2.new, UDim.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local insert, remove, tFind = table.insert, table.remove, table.find
local fontFromName = Font.fromName

return function(plr: Player)
	local scope = Fusion.scoped({})
	local hintsList = Fusion.Value(scope, {})
	local char = plr.Character or plr.CharacterAdded:Wait()

	Components.ScreenGui(scope, {
		Name = "Hints",
		DisplayOrder = 100,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				Position = fromScale(0.5, 0.511),
				Size = fromScale(1, 0.979),
				ZIndex = 999,

				[Children] = {
					New(scope, "UIListLayout")({
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					New(scope, "UIPadding")({ PaddingTop = udNew(0, 10) }),

					Fusion.ForValues(scope, hintsList, function(_, localScope: table, text: string)
						local overallTrans = Fusion.Value(localScope, 0)
						Spawn(function()
							wait(2.7)
							overallTrans:set(1)
						end)

						return Components.TextButton(localScope, {
							Name = "Hint",
							AnchorPoint = v2New(0.5, 0.5),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = fromOffset(0, 27),
							Text = text,
							FontFace = fontFromName("Ubuntu", Enum.FontWeight.Bold),
							TextScaled = false,

							BackgroundTransparency = Fusion.Tween(localScope, Computed(localScope, function(use)
								return use(overallTrans)
							end), AssetBook.TweenInfos.twiceHalf),
							TextTransparency = Fusion.Tween(localScope, Computed(localScope, function(use)
								return use(overallTrans)
							end), AssetBook.TweenInfos.twiceHalf),

							[Fusion.OnEvent("MouseButton1Click")] = function()
								overallTrans:set(1)
							end,

							[Children] = {
								New(localScope, "UICorner")({ CornerRadius = udNew(0.25, 0) }),
								New(localScope, "UIPadding")({
									PaddingLeft = udNew(0, 11),
									PaddingRight = udNew(0, 11),
								}),
							},
						})
					end)
				},
			}),

		},
	})

	local function _createHint(text: string, envir: string)
		local past = Fusion.peek(hintsList)
		insert(past, text)

		hintsList:set(past)
		workspace.Sounds.SFXs[if envir == "Hint" then "NewInfo" else "Error"]:Play()

		wait(3)
		local now = Fusion.peek(hintsList)
		remove(now, tFind(now, text))

		hintsList:set(now)
	end
	Events.CreateHint:Connect(_createHint)
	Signals.CreateHint:Connect(_createHint)

	local function _onDead()
		Events.CreateHint:DisconnectAll()
		Signals.CreateHint:DisconnectAll()

		Fusion.doCleanup(scope)
	end
	char.Humanoid.Died:Once(_onDead)
end
