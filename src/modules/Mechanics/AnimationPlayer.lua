--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.Modules.Data.Events)
local Signals = require(RepS.Modules.Data.Signals)

return function (plr: Player)
	local char = plr.Character or plr.CharacterAdded:Wait()
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
		AlchemistAnim1 = animator:LoadAnimation(animations.ArcherAttack2),
		AlchemistAnim2 = animator:LoadAnimation(animations.AlchemistAttack),
		IllusionistAnim1 = animator:LoadAnimation(animations.WizardAttack),
		IllusionistAnim2 = animator:LoadAnimation(animations.WizardAttack2),
		MagicCastedAnim1 = animator:LoadAnimation(animations.MagicCasted1),
		MagicCastedAnim2 = animator:LoadAnimation(animations.MagicCasted2),

        ArcherCharge = animator:LoadAnimation(animations.ArcherCharge),
		KnightParry = animator:LoadAnimation(animations.KnightParry),
		RogueSlash = animator:LoadAnimation(animations.RogueSlash)
    }

	local function _playAnim(anim: string)
		assert(anims[anim], "No animation found for "..anim.."!")

		anims[anim]:Play()
	end
	Events.PlayAnimation:Connect(_playAnim)
	Signals.PlayAnimation:Connect(_playAnim)

	local function _onDead()
		Events.PlayAnimation:DisconnectAll()
	end
	humanoid.Died:Once(_onDead)
end
