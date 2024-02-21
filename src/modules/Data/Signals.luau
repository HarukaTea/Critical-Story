--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Signal = Warp.Signal

local Signals = {
	CreateHint = Signal("CreateHint"),
	ClientTween = Signal("ClientTween"),
	NPCChat = Signal("NPCChat"),
	PlayAnimation = Signal("PlayAnimation")
}

return Signals
