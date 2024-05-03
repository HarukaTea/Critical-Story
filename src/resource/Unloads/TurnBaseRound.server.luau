--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local CSAttackUtil = require(SSS.Modules.Utils.CSAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(SSS.Modules.Data.ServerSignals)

local cage = script.Parent :: Model
local owner = cage:WaitForChild("Owner") :: ObjectValue

local wait = task.wait
local insert = table.insert

local function turnBaseCombatRound(monster: Model, isFirstRound: boolean)
    if not monster then return end
    if not monster:FindFirstChild("TargetingList") then return end

	local locator: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent

	--pcall(function()
		if isFirstRound then
			local mobs = {}
			for _, mob in locator:GetDescendants() do
				if mob:HasTag("Monster") and mob.PrimaryPart then mobs[#mobs + 1] = mob end
			end

			ServerUtil:SortMonsters(mobs, cage)
		end

		--// Player phase
		monster = locator:FindFirstChildWhichIsA("Model", true)
		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			Events.FreezePlayerControls:Fire(plr, "Freeze")
			Events.CameraPointTo:Fire(plr, cage.Cam)
		end
		ServerUtil:SortPlayers(ServerUtil:GetPlayersByMonster(monster), monster, cage)

		wait(2)
		monster = locator:FindFirstChildWhichIsA("Model", true)
		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			plr:SetAttribute("NextAction", "")
			plr:SetAttribute("NextItem", nil)

			Events.NewPhase:Fire(plr, if isFirstRound then "Combat" else "Player")
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.PlayerPhaseStart)
		end

		--// Wait
		local maxTimeOut = 15
		local function _playerAllDoneCheck() : boolean
			local check = true

			monster = locator:FindFirstChildWhichIsA("Model", true)
			for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
				if not plr then continue end
				if plr:GetAttribute("NextAction") == "" then check = false break end
			end

			return check
		end
		repeat wait(1) maxTimeOut -= 1 until _playerAllDoneCheck() or maxTimeOut <= 0

		--// Player execution phase
		monster = locator:FindFirstChildWhichIsA("Model", true)
		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			Events.NewPhase:Fire(plr, "Execution")
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)

			Spawn(function()
				wait(0.5)
				local nextAction = plr:GetAttribute("NextAction") :: string

				if nextAction == "Attack" then
					CSAttackUtil[plr:GetAttribute("Class")](plr)

				elseif nextAction == "Items" then
					local item = plr:GetAttribute("NextItem") :: string
					if not item then return end

					Signals.UseItem:Fire(plr, item)

				else
					--- pass or defend
					plr:SetAttribute("NextAction", "Defend")

					SkillUtil:DefenseBuff(plr, 30, 1)
					SkillUtil:RestoreTP(plr, 30)
				end
			end)
		end

		wait(2)
		--// Mob phase
		monster = locator:FindFirstChildWhichIsA("Model", true)
		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			local char = plr.Character

			char.Humanoid.AutoRotate = true

			Events.NewPhase:Fire(plr, "Mob")
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.MobPhaseStart)
			Events.CreateCombatBorder:Fire(plr, "Create", locator)
			Events.CameraPointTo:Fire(plr, "Reset")
			Events.FreezePlayerControls:Fire(plr, "Unfreeze")

			char:SetAttribute("OrbAttackingTime", true)
		end
		for _, mob in locator:GetDescendants() do
			if mob:HasTag("Monster") and mob.PrimaryPart then mob.Attack.Disabled = false end
		end

		--// Prepare to end
		wait(13.5)
		for _, mob in locator:GetDescendants() do
			if mob:HasTag("Monster") and mob.PrimaryPart then mob.Attack.Disabled = true end
		end

		--// End mob phase
		wait(1.5)
		local attacks, mobs = {}, {}
		for _, mob in locator:GetDescendants() do
			if mob:HasTag("Monster") and mob.PrimaryPart then
				if not mob:FindFirstChild("Holder") then continue end
				if not mob.Holder.Value then continue end

				for _, attack: Instance in mob.Holder.Value:GetDescendants() do
					if attack:IsA("BasePart") then
						if attack.Transparency < 1 then insert(attacks, attack) end
					end
					attack:RemoveTag("MonsterDMG")
				end

				mobs[#mobs + 1] = mob
			end
		end
		ServerUtil:SortMonsters(mobs, cage)

		monster = locator:FindFirstChildWhichIsA("Model", true)
		for _, plr in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			Events.CreateCombatBorder:Fire(plr, "Destroy")
			Events.ClientTween:Fire(plr, attacks, { Transparency = 1 }, "one")

			plr.Character:SetAttribute("OrbAttackingTime", false)

			if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then continue end

			for _, orb: Model in workspace.MapComponents.OrbFolders[plr.Name]:GetChildren() do
				if orb and orb:IsA("Model") and orb.PrimaryPart then orb:SetAttribute("Despawn", true) end
			end
		end

		turnBaseCombatRound(monster)
	--end)
end

turnBaseCombatRound(owner.Value, true)
