--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Pinia = require(RepS.Modules.UI.Pinia.NPCChatPinia)

local ChatFrame = require(RepS.Modules.UI.Views.ChatFrame)

local NPCChat = {}
NPCChat.__index = NPCChat
NPCChat.__type = "NPCChat"

local wait = task.wait
local v2New = Vector2.new
local fromScale = UDim2.fromScale

return function(plr: Player)
	local self = setmetatable({}, NPCChat)

	self.plr = plr
	self.plrGui = plr.PlayerGui
	self.char = plr.Character or plr.CharacterAdded:Wait()

	repeat wait() until plr:GetAttribute("PlayerDataLoaded")
	repeat wait() until self.char:GetAttribute("CharDataLoaded")

	Pinia(self)

	local scope = self.scope
	Components.ScreenGui(scope, {
		Name = "NPCChat",
		DisplayOrder = 2,
		Parent = self.plrGui,

		[Fusion.Children] = {
			Components.Frame(scope, {
				Name = "BottomBG",
				AnchorPoint = v2New(0.5, 0.9),
				Position = fromScale(0.5, 1),
				Size = fromScale(1, 0.1),
				ZIndex = 2,

				[Fusion.Children] = {
					Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.697 }),

					ChatFrame(self),
				},
			})
		},
	})

	local function _clearGarbage()
		CAS:UnbindAction("NextDialogue")
		ClientUtil:FreezePlayerControls("Unfreeze")

		Events.NPCChat:DisconnectAll()

		Signals.NPCChat:DisconnectAll()
		Signals.StartNPCChat:DisconnectAll()

		self.Empty()

		Fusion.doCleanup(scope)

		self = nil
	end
	self.char.Humanoid.Died:Once(_clearGarbage)
end
