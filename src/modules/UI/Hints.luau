--!nocheck

local LocalizationService = game:GetService("LocalizationService")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Pinia = require(RepS.Modules.UI.Pinia.HintsPinia)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local Hints = {}
Hints.__index = Hints

local wait = task.wait
local v2New, udNew = Vector2.new, UDim.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local insert, remove, tFind = table.insert, table.remove, table.find
local fontFromName = Font.fromName

return function(plr: Player)
	local self = setmetatable({}, Hints)

	self.char = plr.Character or plr.CharacterAdded:Wait()
	self.translator = LocalizationService:GetTranslatorForPlayer(plr)
	self.displayOrder = 1

	Pinia(self)

	local scope = self.scope :: Fusion.Scope
	Components.ScreenGui(scope, {
		Name = "Hints",
		DisplayOrder = 100,
		Parent = plr:FindFirstChildOfClass("PlayerGui"),

		[Children] = {
			Components.Frame(scope, {
				Name = "HintsBG",
				Position = fromScale(0.5, 0.25),
				ZIndex = 999,

				[Children] = {
					New(scope, "UIListLayout")({
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
					}),
					New(scope, "UIPadding")({ PaddingTop = udNew(0, 10) }),

					Fusion.ForValues(scope, self.hintsList, function(_, localScope: Fusion.Scope, text: string)
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
							LayoutOrder = self.displayOrder,

							BackgroundTransparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
								return use(overallTrans)
							end), AssetBook.TweenInfos.twiceHalf),
							TextTransparency = Fusion.Tween(localScope, Computed(localScope, function(use: Fusion.Use)
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
			Components.Frame(scope, {
				Name = "FullScreenHintBG",
				BackgroundColor3 = Color3.new(1, 1, 1),

				BackgroundTransparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
					return use(self.fullScreenTrans)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = {
					Components.Frame(scope, {
						Name = "Center",
						AnchorPoint = v2New(0.5, 0),
						Size = fromScale(1, 0.1),
						Position = fromScale(0.5, 0.5),

						[Children] = {
							New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.627 }),

							Components.TextLabel(scope, {
								Name = "Hint",
								AnchorPoint = v2New(0.5, 0.5),
								Position = fromScale(0.5, 0.5),
								Size = fromScale(1, 0.6),
								TextColor3 = Color3.new(),

								Text = Computed(scope, function(use: Fusion.Use)
									return use(self.fullScreenText)
								end),
								TextTransparency = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
									return use(self.fullScreenTrans)
								end), AssetBook.TweenInfos.twiceHalf),

								[Children] = {
									New(scope, "UITextSizeConstraint")({ MaxTextSize = 36 }),
								},
							}),
						}
					})
				}
			})
		},
	})

	--// Connections
	local function _createHint(text: string)
		local past = Fusion.peek(self.hintsList)
		text = self.translator:Translate(game, text)

		insert(past, text)

		self.displayOrder += 1
		if self.displayOrder == math.huge - 1 then self.displayOrder = 1 end

		self.hintsList:set(past)
		workspace.Sounds.SFXs.Error:Play()

		wait(3)
		local now = Fusion.peek(self.hintsList)
		remove(now, tFind(now, text))

		self.hintsList:set(now)
	end
	local function _createFSHint(text: string, state: boolean)
		text = self.translator:Translate(game, text)

		self.fullScreenTrans:set(if state then 0 else 1)
		self.fullScreenText:set(text)
	end
	table.insert(scope, Events.CreateHint.On(function(data)
		_createHint(data.Hint)
	end))
	table.insert(scope, Events.CreateFullScreenHint.On(function(data)
		_createFSHint(data.Hint, data.State)
	end))
	table.insert(scope, Signals.CreateHint:Connect(_createHint))
	table.insert(scope, Signals.CreateFullScreenHint:Connect(_createFSHint))


	--// Clear
	local function _onDead()
		Fusion.doCleanup(scope)
	end
	self.char.Humanoid.Died:Once(_onDead)
end
