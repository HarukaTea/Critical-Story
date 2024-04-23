--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AttackUtil = require(SSS.Modules.Utils.AttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local Future = require(RepS.Modules.Packages.Future)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local floor, random = math.floor, math.random
local fromRGB = Color3.fromRGB
local wait = task.wait

--[[
    So mob is ready to combat too
]]
local function turnBaseCombatStart(monster: Model)
    if not monster then return end
    if not monster:FindFirstChild("TargetingList") then return end

	--// Player phase
	wait(0.6)
	for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
		if not plr then continue end

		plr:SetAttribute("NextAction", "")

		Events.FreezePlayerControls:Fire(plr, "Unfreeze")
		Events.NewPhase:Fire(plr, "Combat")
		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.PlayerPhaseStart)
	end

	--// Wait
	local function _playerAllDoneCheck() : boolean
		local check = true

		for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
			if not plr then continue end
			if plr:GetAttribute("NextAction") == "" then check = false end
		end

		return check
	end
	repeat wait() until _playerAllDoneCheck()

	--// Player execution phase
	for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
		if not plr then continue end

		Events.NewPhase:Fire(plr, "Execution")
		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Up)

		Spawn(function()
			local nextAction = plr:GetAttribute("NextAction") :: string
			if nextAction == "Attack" then
				plr.Character:SetAttribute("AttackingTime", true)

				wait(6)
				if plr and plr.Character then plr.Character:SetAttribute("AttackingTime", false) end

			elseif nextAction == "Items" then

			elseif nextAction == "Skills" then

			else
				SkillUtil:DefenseBuff(plr, 30, 1)
			end
		end)
	end

	wait(6)
	--// Mob phase
	local locator: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent

	for _, plr: Player in ServerUtil:GetPlayersByMonster(monster) do
		if not plr then continue end

		Events.NewPhase:Fire(plr, "Mob")
		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.MobPhaseStart)
		Events.FreezePlayerControls:Fire(plr, "Freeze")
	end
	if locator:FindFirstChildOfClass("Part") then
		for _, subMonster in locator:GetDescendants() do
			if subMonster:HasTag("Monster") and subMonster:GetAttribute("SubMonster") then
				Signals.MobPhaseStart:Fire(subMonster)
			end
		end
	end

	turnBaseCombatStart(locator:FindFirstChildWhichIsA("Model", true))
end

--[[
	Combat starts! Good luck players
]]
local function combatStartSetup(plr: Player, monster: Model)
	--- if monster was occupied by another player, we will return it
	if monster:GetAttribute("InCombat") then return end

	ServerUtil:AddTargetForMonster(plr, monster)
	ServerUtil:MonsterActivateCombat(monster)

	--- sub-monster exist
	if monster.Parent:FindFirstChildOfClass("Part") then
		for _, subMonster in monster.Parent:GetDescendants() do
			if subMonster:HasTag("Monster") and subMonster:GetAttribute("SubMonster") then
				ServerUtil:AddTargetForMonster(plr, subMonster)

				if not subMonster:GetAttribute("InCombat") then
					ServerUtil:MonsterActivateCombat(subMonster)
				end
			end
		end
	end

	turnBaseCombatStart(monster)
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
	local atk = char:GetAttribute("ATKDMG") :: number
	local baseDamage = random(floor(atk * 0.9), floor(atk * 1.1))

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
	if AttackUtil[style] then AttackUtil[style](plr, monster, baseDamage, orb) end

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
local function nextActionRequest(plr: Player, action: string)
	if plr:GetAttribute("NextAction") ~= "" then return end

	plr:SetAttribute("NextAction", "Attack")
end
Events.NextActionRequest:Connect(nextActionRequest)
