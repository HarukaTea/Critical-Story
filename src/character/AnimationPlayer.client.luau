--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(RepS.Modules.Data.Events)
local Signals = require(RepS.Modules.Data.Signals)

local char = script.Parent :: Model
local humanoid = char:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

local animations = RepS.Package.Animations :: Folder

local anims = {
	WarriorAnim1 = animator:LoadAnimation(animations.WarriorAttack),
	WarriorAnim2 = animator:LoadAnimation(animations.WarriorAttack2),
	ArcherAnim1 = animator:LoadAnimation(animations.ArcherAttack),
	ArcherAnim2 = animator:LoadAnimation(animations.ArcherAttack2),
	WizardAnim1 = animator:LoadAnimation(animations.WizardAttack),
	WizardAnim2 = animator:LoadAnimation(animations.WizardAttack2),
	KnightAnim1 = animator:LoadAnimation(animations.KnightAttack),
	KnightAnim2 = animator:LoadAnimation(animations.KnightAttack2),
	RogueAnim1 = animator:LoadAnimation(animations.WarriorAttack),
	RogueAnim2 = animator:LoadAnimation(animations.WarriorAttack2),
	RepeaterAnim1 = animator:LoadAnimation(animations.RepeaterAttack),
	RepeaterAnim2 = animator:LoadAnimation(animations.RepeaterAttack2),
	StrikerAnim1 = animator:LoadAnimation(animations.StrikerAttack),
	StrikerAnim2 = animator:LoadAnimation(animations.WarriorAttack2),
	AlchemistAnim1 = animator:LoadAnimation(animations.ArcherAttack),
	AlchemistAnim2 = animator:LoadAnimation(animations.AlchemistAttack),
	IllusionistAnim1 = animator:LoadAnimation(animations.WizardAttack),
	IllusionistAnim2 = animator:LoadAnimation(animations.WizardAttack2),

	FireStaffAnim1 = animator:LoadAnimation(animations.WizardAttack),
	FireStaffAnim2 = animator:LoadAnimation(animations.WizardAttack2),
	MagicCastedAnim1 = animator:LoadAnimation(animations.MagicCasted1),
	MagicCastedAnim2 = animator:LoadAnimation(animations.MagicCasted2),

	Bounce = animator:LoadAnimation(animations.Bounce)
}

--// Connections
local function playAnim(anim: string)
	if not anims[anim] then warn("Can't found animation: "..anim.."!") return end

	if anim == "MagicCastedAnim1" then
		local class = Players.LocalPlayer:GetAttribute("Class") :: string
		if AssetBook.ClassInfo[class].Type == "Magic" then anim = "MagicCastedAnim2" end
	end

	anims[anim]:Play()
end
Events.PlayAnimation:Connect(playAnim)
Signals.PlayAnimation:Connect(playAnim)

--// Clear
local function onDead()
	Events.PlayAnimation:DisconnectAll()
	Signals.PlayAnimation:DisconnectAll()

	--// 256 limit still happens, idk
	for _, anim: AnimationTrack in anims do
		anim:Stop(0)
		anim:Destroy()
	end
	local animTracks = animator:GetPlayingAnimationTracks()
	for _, track: AnimationTrack in animTracks do
		track:Stop(0)
		track:Destroy()
	end
end
humanoid.Died:Once(onDead)
