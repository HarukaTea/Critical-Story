--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local CAAttackUtil = require(SSS.Modules.Utils.CAAttackUtil)
local CSAttackUtil = require(SSS.Modules.Utils.CSAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(SSS.Modules.Data.ServerSignals)

local floor, random = math.floor, math.random
local fromRGB = Color3.fromRGB
local wait = task.wait
local insert = table.insert
local cfNew = CFrame.new
local v3New = Vector3.new

--[[
    mob is ready to combat
]]
local function turnBaseCombatRound(monster: Model, isFirstRound: boolean)
    if not monster then return end
    if not monster:FindFirstChild("TargetingList") then return end

	local cage = monster.CageHolder.Value :: Model
	local locator: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent

	pcall(function()
		if isFirstRound then
			local mobs = {}
			for _, mob in locator:GetDescendants() do
				if mob:HasTag("Monster") and mob.PrimaryPart then mobs[#mobs + 1] = mob end
			end

			ServerUtil:SortMonsters(mobs, cage)
		end

		--// Player phase
		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			Events.FreezePlayerControls:Fire(plr, "Freeze")
			Events.CameraPointTo:Fire(plr, cage.Cam)
		end
		ServerUtil:SortPlayers(ServerUtil:GetPlayersByMonster(monster), monster, cage)

		wait(2)
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

			for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
				if not plr then continue end
				if plr:GetAttribute("NextAction") == "" then check = false break end
			end

			return check
		end
		repeat wait(1) maxTimeOut -= 1 until _playerAllDoneCheck() or maxTimeOut <= 0

		--// Player execution phase
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
		wait(13)
		for _, mob in locator:GetDescendants() do
			if mob:HasTag("Monster") and mob.PrimaryPart then mob.Attack.Disabled = true end
		end

		--// End mob phase
		wait(2)
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

		for _, plr in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end

			Events.CreateCombatBorder:Fire(plr, "Destroy")
			Events.ClientTween:Fire(plr, attacks, { Transparency = 1 }, "one")

			plr.Character:SetAttribute("OrbAttackingTime", false)

			if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then continue end

			for _, orb: Model in workspace.MapComponents.OrbFolders[plr.Name]:GetChildren() do
				if orb and orb.PrimaryPart then orb:SetAttribute("Despawn", true) end
			end
		end

		turnBaseCombatRound(locator:FindFirstChildWhichIsA("Model", true))
	end)
end

--[[
	Combat starts! Good luck players
]]
local function combatStartSetup(plr: Player, monster: Model)
	--- if monster was occupied by another player, we will return it
	if monster:GetAttribute("InCombat") then return end

	local locator: BasePart = monster.Parent
	local combatMode = plr:GetAttribute("CombatMode") :: string

	if combatMode == "Public" then
		monster:SetAttribute("InCombat", true)

		local char = plr.Character
		char:PivotTo(cfNew(locator.Position + v3New(0, 8, 0)))
		char.PrimaryPart.Anchored = true

		local border = RepS.Package.Unloads.PublicBorder:Clone() :: Model
		border:PivotTo(cfNew(locator.Position))
		border.Parent = char

		wait(5)
		if not char then monster:SetAttribute("InCombat", false) return end
		if not char.PrimaryPart then monster:SetAttribute("InCombat", false) return end

		local maxPlayer = 0
		for _, player: Player in Players:GetPlayers() do
			if not player then continue end
			if not player.Character then continue end
			if not player.Character.PrimaryPart then continue end
			if maxPlayer >= 4 then break end
			if player == plr then continue end

			if (player.Character.PrimaryPart.Position - locator.Position).Magnitude <= 22 then
				maxPlayer += 1

				for _, mob in locator:GetDescendants() do
					if mob:HasTag("Monster") and mob.PrimaryPart then ServerUtil:AddTargetForMonster(player, mob) end
				end
			end
		end

		border:Destroy()
		char.PrimaryPart.Anchored = false
	end

	for _, mob in locator:GetDescendants() do
		if mob:HasTag("Monster") and mob.PrimaryPart then
			ServerUtil:AddTargetForMonster(plr, mob)

			if combatMode == "Public" then ServerUtil:MonsterActivateCombat(mob) continue end
			if not mob:GetAttribute("InCombat") then ServerUtil:MonsterActivateCombat(mob) end
		end
	end

	turnBaseCombatRound(monster, true)
end
Events.CombatStart:Connect(combatStartSetup)


--[[
	Player hit the orb and deal dmg to mobs
]]
local function mobTakeDMG(plr: Player, orb: Model)
	local char = plr.Character :: Model
	local HRP = char.PrimaryPart

	--- pre checks
	if not orb then return end
	if not orb:FindFirstChild("Owner") then return end
	if orb.Owner.Value ~= char then return end
	if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
	if not char.CharStats.TargetMonster.Value then return end
	if not HRP then return end
	if not orb.Parent then return end
	if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then return end

	local monster = char.CharStats.TargetMonster.Value :: Model
	local class = orb:GetAttribute("Style") :: string
	local dmgType = if orb:GetAttribute("DMGType") then orb:GetAttribute("DMGType") else AssetBook.ClassInfo[class].Type
	local baseDamage = 0
	if dmgType == "DMG" then
		local minDMG: number, maxDMG: number = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
		baseDamage = if minDMG >= maxDMG then maxDMG else random(minDMG, maxDMG)
	else
		baseDamage = char:GetAttribute("Magic")
	end

	orb.Owner:Destroy()

	--- final check
	if not monster.PrimaryPart then return end
	if monster:GetAttribute("CantAttack") then baseDamage = 0 end

	--- extra effects
	local burnChance = plr.Character:GetAttribute("BurnChance") :: number
	if burnChance > 0 then
		local burn = LootPlan.new()

		burn:Add("Burn", burnChance)
		burn:Add("None", 100 - burnChance)

		if burnChance:Roll() == "Burn" then SkillUtil:Burn(plr, monster, 6) end

		burn:Destroy()
	end

	local subStyle = orb:GetAttribute("SubStyle") :: string?
	local style = if subStyle then subStyle else orb:GetAttribute("Style") :: string
	if CAAttackUtil[style] then CAAttackUtil[style](plr, monster, baseDamage, orb) end

	orb:Destroy()
end
Events.MobTakeDMG:Connect(mobTakeDMG)

--[[
	Character is taking damage rn
]]
local function charTakeDMG(plr: Player, dmgPart: Model)
	if not dmgPart then return end
	if not dmgPart.Parent then return end
    if not dmgPart:FindFirstChild("Owner") then return end
	if not dmgPart.Owner.Value then return end

	local char = plr.Character :: Model
	local humanoid = char.Humanoid :: Humanoid
    local monster = dmgPart.Owner.Value :: Model | string
	local shield = char:GetAttribute("Shield") :: number
	local dmg = monster:GetAttribute("Damage") :: number

    --- if attacker is void
	if monster == "Abyss" then
		char.Humanoid:TakeDamage(char.Humanoid.MaxHealth + 1)
		return
	end

	--- dodge roll
	local dodgeChance = char:GetAttribute("DodgeChance") :: number
	if dodgeChance > 0 then
		local dodge = LootPlan.new()

		dodge:Add("Dodge", dodgeChance)
		dodge:Add("None", 100 - dodgeChance)

		if dodge:Roll() == "Dodge" then
			ServerUtil:ShowText(char, "BLOCKED!", fromRGB(255, 255, 255))

			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Blocked)

			dodge:Destroy()
			return
		end
		dodge:Destroy()
	end

    --- some extra damage
    if dmgPart:GetAttribute("Burn") then SkillUtil:Burn(plr, monster, 6, true) end
    if dmgPart:GetAttribute("Poison") then SkillUtil:Poison(plr, monster, 6, true) end

    --- defense reduce
    dmg = floor(dmg * (100 - char:GetAttribute("Defense")) / 100)

	--- Knight class skills
	if char:GetAttribute("Guard") > 0 then
        local oriDmg = dmg
		dmg = floor(oriDmg - (oriDmg * char:GetAttribute("Guard")) / 100)

		char:SetAttribute("Guard", 0)
	end

	--- shield
	if shield > 0 then
		if dmgPart:GetAttribute("Pierce") then -- "Pierce"
			humanoid:TakeDamage(dmg)
			ServerUtil:ShowNumber(char, dmg)
			return
		end

		if dmg > shield then
			humanoid:TakeDamage(floor(dmg - shield))
			ServerUtil:ShowNumber(char, dmg - shield)

			char:SetAttribute("Shield", 0)
			return
		end

		HarukaLib:Add(char, "Shield", -dmg)
		ServerUtil:ShowNumber(char, dmg, fromRGB(122, 122, 122))
		return
	end

	humanoid:TakeDamage(dmg)
	ServerUtil:ShowNumber(char, dmg)
end
Events.CharTakeDMG:Connect(charTakeDMG)

--[[
	Player request to do next action
]]
local function nextActionRequest(plr: Player, action: string, extra: string?)
	if plr:GetAttribute("NextAction") ~= "" then return end
	if action == "Items" then plr:SetAttribute("NextItem", extra) end

	plr:SetAttribute("NextAction", action)
end
Events.NextActionRequest:Connect(nextActionRequest)
