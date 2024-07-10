--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local CAAttackUtil = require(SSS.Modules.Utils.CAAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local floor, random = math.floor, math.random
local fromRGB = Color3.fromRGB
local wait = task.wait
local cfNew = CFrame.new


local function combatStartSetup(plr: Player, locator: BasePart)
	--- if monster was occupied by another player, we will return it
	if locator:GetAttribute("InCombat") then return end
	if locator:GetAttribute("SubMonster") then return end

	local combatMode = plr:GetAttribute("CombatMode") :: string
	local monster = ServerUtil:SetupMonster(locator)
	for _, subLocator: BasePart in locator:GetDescendants() do
		if subLocator:HasTag("MonsterLocation") and subLocator:IsA("BasePart") then
			ServerUtil:SetupMonster(subLocator)
		end
	end

	local check = true
	if combatMode == "Public" then
		locator:SetAttribute("InCombat", true)
		monster:SetAttribute("InCombat", true)

		local char = plr.Character
		char:PivotTo(cfNew(locator.Position) * cfNew(0, 8, 0))
		char.PrimaryPart.Anchored = true

		local border = RepS.Package.Unloads.PublicBorder:Clone() :: Model
		border:PivotTo(cfNew(locator.Position))
		border.Parent = char

		wait(5)
		Promise.new(function(resolve, reject)
			if char.Humanoid.Health <= 0 then reject() end
			if not monster.PrimaryPart then reject() end

			resolve()

		end):Then(function()
			local maxPlayer = 0
			for _, player: Player in Players:GetPlayers() do
				if maxPlayer >= 4 then break end
				if player == plr then continue end

				pcall(function()
					local distance = player:DistanceFromCharacter(monster.PrimaryPart.Position)

					if distance <= 22 and distance > 0 then
						maxPlayer += 1

						for _, mob: Model in locator:GetDescendants() do
							if mob:HasTag("Monster") and mob.PrimaryPart then
								ServerUtil:AddTargetForMonster(player, mob)

								HarukaLib:AddAttr(monster, "MaxHealth", monster:GetAttribute("Health"))
							end
						end
					end
				end)
			end

			border:Destroy()
			char.PrimaryPart.Anchored = false

		end):Catch(function()
			locator:SetAttribute("InCombat", false)
			monster:SetAttribute("InCombat", false)

			check = false
		end)
	end
	if not check then return end

	--// Activate
	for _, mob: Model in locator:GetDescendants() do
		if mob:HasTag("Monster") and mob.PrimaryPart then
			ServerUtil:AddTargetForMonster(plr, mob)

			mob:SetAttribute("Health", mob:GetAttribute("MaxHealth"))

			if combatMode == "Public" then ServerUtil:MonsterActivateCombat(mob) continue end
			if not mob:GetAttribute("InCombat") then ServerUtil:MonsterActivateCombat(mob) end
		end
	end
end
Events.CombatStart:Connect(combatStartSetup)


local function mobTakeDMG(plr: Player, orb: Model)
	local char = plr.Character :: Model

	--- pre checks
	local check = true
	Promise.new(function(_, reject)
		if orb.Owner.Value ~= char then reject() end
		if (char.PrimaryPart.Position - orb.PrimaryPart.Position).Magnitude > 16 then reject() end

	end):Catch(function()
		check = false
	end)
	if not check then return end

	--- dmg calculations
	local monster = char.CharStats.TargetMonster.Value :: Model?
	local class = orb:GetAttribute("Style") :: string
	local dmgType = if orb:GetAttribute("DMGType") then orb:GetAttribute("DMGType") else AssetBook.ClassInfo[class].Type

	--- base damage
	local baseDamage = 0
	if dmgType == "DMG" then
		local minDMG: number, maxDMG: number = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")

		baseDamage = if minDMG >= maxDMG then random(maxDMG, minDMG) else random(minDMG, maxDMG)
	else
		baseDamage = char:GetAttribute("Magic")
	end
	baseDamage = floor(baseDamage)

	--- attack
	orb.Owner:Destroy()

	pcall(function()
		if monster:GetAttribute("CantAttack") then baseDamage = 0 end

		--- attack
		local subStyle = orb:GetAttribute("SubStyle") :: string?
		local style = if subStyle then subStyle else orb:GetAttribute("Style") :: string

		if CAAttackUtil[style] then CAAttackUtil[style](plr, monster, baseDamage, orb) end
		orb:Destroy()

		--- extra attack
		local extraAttacks = { "Burn", "Poison" }
		for i = 1, 2 do
			local charCurrentChance = char:GetAttribute(extraAttacks[i].."Chance")
			local result = HarukaLib:RollLoot({
				[extraAttacks[i].."Chance"] = charCurrentChance,
				["None"] = 100 - charCurrentChance
			})

			if result == extraAttacks[i].."Chance" then BuffEffectsUtil[extraAttacks[i]](BuffEffectsUtil, char, monster, 6) end
		end
	end)
end
Events.MobTakeDMG:Connect(mobTakeDMG)


local function charTakeDMG(plr: Player, dmgPart: Model)
	if not dmgPart then return end
	if not dmgPart.Parent then return end
    if not dmgPart:FindFirstChild("Owner") then return end
	if not dmgPart.Owner.Value then return end

	local char = plr.Character :: Model
	local humanoid = char.Humanoid :: Humanoid
    local monster = dmgPart.Owner.Value :: Model?
	local shield = char:GetAttribute("Shield") :: number
	local dmg = monster:GetAttribute("Damage") :: number

	--- dodge roll
	local dodgeChance = char:GetAttribute("DodgeChance") :: number
	if dodgeChance > 0 then
		local result = HarukaLib:RollLoot({
			["Dodge"] = dodgeChance,
			["None"] = 100 - dodgeChance
		})

		if result == "Dodge" then
			ServerUtil:ShowText(char, "BLOCKED!", fromRGB(255, 255, 255))

			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Blocked)
			return
		end
	end

	--- some hit cd detections
	if char:GetAttribute("CurrentState") == "Hit" then char:SetAttribute("CurrentState", "None") end -- refresh hit cd
    char:SetAttribute("CurrentState", "Hit")

    --- some extra damage
    if dmgPart:HasTag("Burn") then BuffEffectsUtil:Burn(char, monster, 6, true) end
    if dmgPart:HasTag("Poison") then BuffEffectsUtil:Poison(char, monster, 6, true) end

    --- defense reduce
    dmg = floor(dmg * (100 - char:GetAttribute("Defense")) / 100)

	--- Knight class skills
	if char:GetAttribute("Guard") > 0 then
        local oriDmg = dmg
		dmg = floor(oriDmg - (oriDmg * char:GetAttribute("Guard")) / 100)

		ServerUtil:ShowText(char, "GUARDED!", AssetBook.ClassInfo.Knight.Color)

		char:SetAttribute("Guard", 0)
	end

	--- shield
	if shield > 0 then
		if dmgPart:HasTag("Pierce") then
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

		HarukaLib:AddAttr(char, "Shield", -dmg)
		ServerUtil:ShowNumber(char, dmg, fromRGB(122, 122, 122))
		return
	end

	humanoid:TakeDamage(dmg)
	ServerUtil:ShowNumber(char, dmg)
end
Events.CharTakeDMG:Connect(charTakeDMG)
