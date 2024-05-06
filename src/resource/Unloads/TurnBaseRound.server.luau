--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local CSAttackUtil = require(SSS.Modules.Utils.CSAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(SSS.Modules.Data.ServerSignals)

local cage = script.Parent :: Model
local owner = cage:WaitForChild("Owner") :: ObjectValue

local wait = task.wait
local insert = table.insert
local floor = math.floor

local function turnBaseCombatRound(monster: Model, isFirstRound: boolean)
	local locator: BasePart, mainMonster: Model, targetPlayers : table
	local function _refreshTargets()
		mainMonster = locator:FindFirstChildWhichIsA("Model", true)
		targetPlayers = ServerUtil:GetPlayersByMonster(mainMonster)
	end

	Promise.new(function()
		locator = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent

		--// First round actions
		_refreshTargets()
		if isFirstRound then
			local mobs = {}
			for _, mob: Instance in locator:GetDescendants() do
				if mob:HasTag("Monster") then mobs[#mobs + 1] = mob end
			end

			ServerUtil:SortMonsters(mobs, cage)
		end

		--// Player phase ready
		for _, plr: Player in targetPlayers do
			Events.FreezePlayerControls:Fire(plr, "Freeze")
			Events.CameraPointTo:Fire(plr, cage.Cam)
		end
		ServerUtil:SortPlayers(targetPlayers, monster, cage)

		--// Player phase start
		wait(1.5)
		_refreshTargets()
		--// Buff phase
		for _, plr: Player in targetPlayers do
			pcall(function()
				for _, buff: Script in plr.Character.CharStats.EffectsList:GetChildren() do
					HarukaLib:Add(buff, "Turn", -1)
				end
			end)
		end
		--// Selections phase
		for _, plr: Player in targetPlayers do
			plr:SetAttribute("NextAction", "")
			plr:SetAttribute("NextItem", nil)

			Events.NewPhase:Fire(plr, if isFirstRound then "Combat" else "Player")
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.PlayerPhaseStart)
		end

		--// Wait
		local maxTimeOut = 15
		local function _playerAllDoneCheck() : boolean
			local check = true

			_refreshTargets()

			for _, plr: Player in targetPlayers do
				if plr:GetAttribute("NextAction") == "" then check = false break end
			end

			return check
		end
		repeat wait(1) maxTimeOut -= 1 until _playerAllDoneCheck() or maxTimeOut <= 0

		--// Player execution phase
		_refreshTargets()
		for _, plr: Player in targetPlayers do
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
					local char = plr.Character

					plr:SetAttribute("NextAction", "Defend")

					BuffEffectsUtil:DefenseBuff(char, 10, 1)
					BuffEffectsUtil:RestoreTP(char, 15)

					HarukaLib:Add(char, "Shield", floor(char:GetAttribute("MaxShield") * 0.2))
				end
			end)
		end

		--// Mob phase
		wait(2)
		_refreshTargets()

		for _, plr: Player in targetPlayers do
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
				pcall(function()
					for _, attack: Instance in mob.AttackHolder.Value:GetDescendants() do
						if attack:IsA("BasePart") then
							if attack.Transparency < 1 then insert(attacks, attack) end
						end
						attack:RemoveTag("MonsterDMG")
					end
				end)

				mobs[#mobs + 1] = mob
			end
		end
		ServerUtil:SortMonsters(mobs, cage)
		--// Debuff phase
		for _, mob in locator:GetDescendants() do
			if mob:HasTag("Monster") and mob.PrimaryPart then
				for _, buff: Script in mob.EffectsList:GetChildren() do
					HarukaLib:Add(buff, "Turn", -1)
				end
			end
		end

		_refreshTargets()
		for _, plr in targetPlayers do
			Events.CreateCombatBorder:Fire(plr, "Destroy")
			Events.ClientTween:Fire(plr, attacks, { Transparency = 1 }, "one")

			plr.Character:SetAttribute("OrbAttackingTime", false)

			if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then continue end

			for _, orb: Model in workspace.MapComponents.OrbFolders[plr.Name]:GetChildren() do
				if orb and orb:IsA("Model") and orb.PrimaryPart then orb:SetAttribute("Despawn", true) end
			end
		end

		turnBaseCombatRound(mainMonster)

	end):catch(function()
		script.Parent:Destroy()
	end)
end

turnBaseCombatRound(owner.Value, true)
