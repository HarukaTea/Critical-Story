--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
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
	RepeaterAnim1 = animator:LoadAnimation(animations.RepeaterAttack),
	RepeaterAnim2 = animator:LoadAnimation(animations.RepeaterAttack2),
	StrikerAnim1 = animator:LoadAnimation(animations.StrikerAttack),
	AlchemistAnim2 = animator:LoadAnimation(animations.AlchemistAttack),
	MagicCastedAnim1 = animator:LoadAnimation(animations.MagicCasted1),
	MagicCastedAnim2 = animator:LoadAnimation(animations.MagicCasted2)
}
-- Prevent animation duplication, but re-edit the table will cause table rehash?
anims.RogueAnim1 = anims.WarriorAnim1
anims.RogueAnim2 = anims.WarriorAnim2
anims.StrikerAnim2 = anims.WarriorAnim2
anims.AlchemistAnim1 = anims.ArcherAnim2
anims.IllusionistAnim1 = anims.WizardAnim1
anims.IllusionistAnim2 = anims.WizardAnim2
anims.FireStaffAnim1 = anims.WizardAnim1
anims.FireStaffAnim2 = anims.WizardAnim2

--// Connections
local function playAnim(anim: string)
	if not anims[anim] then warn("Can't found animation: "..anim.."!") return end

	if anim == "MagicCasted1" then
		local class = Players.LocalPlayer:GetAttribute("Class") :: string
		if AssetBook.ClassInfo[class].Type == "Magic" then anim = "MagicCasted2" end
	end

	anims[anim]:Play()
end
Events.PlayAnimation:Connect(playAnim)
Signals.PlayAnimation:Connect(playAnim)

--// Clear
local function onDead()
	Events.PlayAnimation:DisconnectAll()
	Signals.PlayAnimation:DisconnectAll()

	for _, anim: AnimationTrack in anims do
		anim:Destroy()
	end

	script:Destroy()
end
humanoid.Died:Once(onDead)
