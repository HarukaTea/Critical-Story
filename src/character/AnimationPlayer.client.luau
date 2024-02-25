--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.Modules.Data.Events)
local Signals = require(RepS.Modules.Data.Signals)

local char = script.Parent :: Model
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator
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
	AlchemistAnim1 = animator:LoadAnimation(animations.ArcherAttack2),
	AlchemistAnim2 = animator:LoadAnimation(animations.AlchemistAttack),
	IllusionistAnim1 = animator:LoadAnimation(animations.WizardAttack),
	IllusionistAnim2 = animator:LoadAnimation(animations.WizardAttack2),
	MagicCastedAnim1 = animator:LoadAnimation(animations.MagicCasted1),
	MagicCastedAnim2 = animator:LoadAnimation(animations.MagicCasted2),
}

local function playAnim(anim: string)
	anims[anim]:Play()
end
Events.PlayAnimation:Connect(playAnim)
Signals.PlayAnimation:Connect(playAnim)

local function onDead()
	Events.PlayAnimation:DisconnectAll()
	Signals.PlayAnimation:DisconnectAll()
end
humanoid.Died:Once(onDead)
