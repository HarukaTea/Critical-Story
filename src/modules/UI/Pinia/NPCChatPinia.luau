--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local function NPCChatPinia(self: table)
	self.scope = Fusion.scoped({})
	local function Value(val: any)
		return Fusion.Value(self.scope, val)
	end

    self.chatDialogueAbsSize = Value(24)
    self.chatText = Value("")
    self.chatSpeaker = Value("")
    self.chatChoices = Value({})
    self.triangleVisible = Value(true)
end

return NPCChatPinia
