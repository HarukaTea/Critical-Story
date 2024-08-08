--!nocheck

local BadgeService = game:GetService("BadgeService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Events = require(SSS.Modules.Data.ServerEvents)
local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local MonsterBook = require(RepS.Modules.Data.MonsterBook)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Promise = require(RepS.Modules.Packages.Promise)
local Spawn = require(RepS.Modules.Packages.Spawn)
local RankBook = require(RepS.Modules.Data.RankBook)

local wait = task.wait
local floor, random, rad = math.floor, math.random, math.rad
local cfNew, instanceNew, rayNew, v3New = CFrame.new, Instance.new, Ray.new, Vector3.new
local cfAngles = CFrame.Angles
local fromRGB = Color3.fromRGB
local insert = table.insert
local yAxis = Vector3.yAxis

local ServerUtil = {}

--// Private
local function _optimizeModel(model: Model)
	for _, part: BasePart in model:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("CornerWedgePart") then
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Anchored = false
		end
	end
end
local function _equipWeapon(char: Model, weapon: Model, defaultPart: string)
	local weldPos = weapon:GetAttribute("Position") or defaultPart

	ServerUtil:WeldModel(char[weldPos], weapon)
	_optimizeModel(weapon)

	weapon.Parent = char
end

--// Public

function ServerUtil:WeldModel(part: Part, welded: Model)
	local C = welded:GetChildren()

	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") or C[i]:IsA("CornerWedgePart") then
			local W = instanceNew("Weld")
			W.Part0 = welded.Middle
			W.Part1 = C[i]

			local CJ = cfNew(welded.Middle.Position)
			W.C0 = welded.Middle.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = welded.Middle
		end

		local Y = instanceNew("Weld")
		Y.Part0 = part
		Y.Part1 = welded.Middle
		Y.C0 = cfNew(v3New())
		Y.Parent = Y.Part0
	end

	local h = welded:GetChildren()
	for _, child: BasePart in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then child.Anchored = false end
	end
end


function ServerUtil:EquipWeapon(char: Model, forceClass: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceClass or plr:GetAttribute("Class") :: string
	local styleFolder = RepS.Package.ClassWeapons[class] :: Folder

	if char.Humanoid.Health <= 0 then return end
	if plr:GetAttribute("Cosmetic") and plr:GetAttribute("Cosmetic") ~= "None" then return end

	--- clear existing weapons
	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	--- equip weapon
	if char:GetAttribute("InCombat") == false then --- in case nil
		_equipWeapon(char, styleFolder.WeaponUnequip:Clone(), "Torso")
		_equipWeapon(char, styleFolder.WeaponUnequip2:Clone(), "Torso")

	elseif char:GetAttribute("InCombat") then
		_equipWeapon(char, styleFolder.WeaponEquipped:Clone(), "Right Arm")
		_equipWeapon(char, styleFolder.WeaponEquipped2:Clone(), "Left Arm")
	end
end


function ServerUtil:EquipArmor(char: Model, armorId: string)
	if char.Humanoid.Health <= 0 then return end

	--- clear existing armors
	if char:FindFirstChild("Armor") then char.Armor:Destroy() end
	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	if not armorId then return end

	--- equip armor
	local armor = RepS.Package.Cosmetics[armorId]:Clone() :: Model
	local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "Extra" }

	--- wait character fully loads
	for _, part: string in equipList do
		if part == "Extra" then continue end

		char:WaitForChild(part, 999)
	end

	--- armor optimization
	_optimizeModel(armor)

	--- equip armor
	local function _equipArmorPart(part: string)
		for _, child: BasePart in armor[part]:GetChildren() do
			if child.Name ~= "Middle" then
				local weldC = instanceNew("WeldConstraint")
				weldC.Part0 = child.Parent.Middle
				weldC.Part1 = child
				weldC.Parent = armor
			end
		end

		local weld = instanceNew("Weld")
		weld.Part0 = char:FindFirstChild(if part == "Extra" then "Torso" else part)
		weld.Part1 = armor[part].Middle
		weld.Parent = armor
	end
	for _, part: string in equipList do
		if not armor:FindFirstChild(part) then continue end

		_equipArmorPart(part)
	end

	--- equip weapon
	local function _weldWeapon(weapon: string, part: string)
		if not armor:FindFirstChild(weapon) then return end

		local realWeapon = armor[weapon]:Clone() :: Model
		ServerUtil:WeldModel(char[part.." Arm"], realWeapon)

		realWeapon:AddTag("Weapon")
		realWeapon.Parent = char
	end
	_weldWeapon("HandleLeft", "Left")
	_weldWeapon("HandleRight", "Right")

	armor.Name = "Armor"
	armor.Parent = char
end


function ServerUtil:SetupMonster(locator: Part, forceLevel: number?) : Model
	if not RepS.Package.MonsterModels:FindFirstChild(locator.Name) then return end

	local level = forceLevel or locator:GetAttribute("Levels") :: number
	local monster = RepS.Package.MonsterModels[locator.Name]:Clone() :: Model
	monster:PivotTo(cfNew(locator.Position))
	if not monster:GetAttribute("CantRotate") then monster:PivotTo(cfNew(locator.Position) * cfAngles(0, rad(random(0, 360)), 0)) end
	monster:SetAttribute("Levels", level)

	if monster:GetAttribute("Floatable") then
		local vel = Instance.new("BodyVelocity")
		vel.MaxForce = Vector3.one * math.huge
		vel.Velocity = Vector3.zero
		vel.Parent = monster
	end

	if not locator:GetAttribute("SubMonster") then
		local tierDisplay = RepS.Package.Effects.TierDisplay:Clone() :: BillboardGui
		tierDisplay.Monster.Text = MonsterBook[monster.Name].Name
		tierDisplay.Levels.Text = "Level "..level
		tierDisplay.Parent = monster.Head

		tierDisplay.Enabled = if monster:GetAttribute("HideTag") then false else true
	else
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("MaxHealth", Formula.MonsterHP(level))
	monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
	monster:SetAttribute("EXP", floor(Formula.EXP(level) / 5) * Formula.GlobalEXPMultiplier)
	monster:SetAttribute("Damage", Formula.MonsterDMG(level))
	monster:SetAttribute("InCombat", false)

	local numberDisplay = RepS.Package.Effects.Display:Clone() :: BillboardGui
	numberDisplay.Number.Text = monster:GetAttribute("MaxHealth")
	numberDisplay.Enabled = false
	numberDisplay.Parent = monster.Head

	for _, child: Instance in monster:GetChildren() do
		if child:IsA("Part") and monster:FindFirstChild(child.Name .. "Model") then
			ServerUtil:WeldModel(child, monster[child.Name .. "Model"])
		end
	end
	monster.Parent = locator

	ServerUtil:SetCollisionGroup(monster, "NPC")
	for _, part: Instance in monster:GetDescendants() do
        if part:IsA("UnionOperation") or part:IsA("BasePart") or part:IsA("CornerWedgePart") then
            part.CanTouch = false
            part.CanQuery = false
        end
    end

	locator.Transparency = 1

	return monster
end


function ServerUtil:MonsterActivateCombat(monster: Model)
	monster.Parent:SetAttribute("InCombat", true)
	monster:SetAttribute("InCombat", true)

	if not monster:GetAttribute("SubMonster") then monster.Head.TierDisplay.Enabled = false end
	monster.Head.Display.Enabled = true

	local folder = instanceNew("Folder")
	folder.Name = monster.Name
	folder:AddTag("CombatHolder")
	folder.Parent = workspace.MapComponents.CombatHolders

	local owner = instanceNew("ObjectValue")
	owner.Name = "Owner"
	owner.Value = monster
	owner.Parent = folder

	monster.AttackHolder.Value = folder
	monster.Attack.Disabled = false
end


function ServerUtil:MonsterDefeated(monster: Model, deadPos: Vector3, allowRespawn: boolean?)
	local respawnLocatorTip: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent
	local locator = monster.Parent :: BasePart

	wait(1)
	if monster.AttackHolder.Value then monster.AttackHolder.Value:Destroy() end

	local defeatedEffect = RepS.Package.Effects.DefeatedEffect:Clone() :: Part
	defeatedEffect.Position = deadPos
	defeatedEffect.Parent = workspace
	Debris:AddItem(defeatedEffect, 1)

	if not allowRespawn or locator:GetAttribute("CantRespawn") then
		monster:Destroy()
		return
	end

	--- multi-combat mechanic
	local waitingLocators = {}
	if monster.WaitingList:FindFirstChildOfClass("ObjectValue") then
		for _, waitingMonster: ObjectValue in monster.WaitingList:GetChildren() do
			insert(waitingLocators, waitingMonster.Value)
		end
	end
	local respawnTimer = RepS.Package.Unloads.RespawnTimer:Clone() :: Part
	respawnTimer.Position = respawnLocatorTip.Position
	respawnTimer.Parent = workspace

	SS.Resources.Unloads.RespawnCountdown:Clone().Parent = respawnTimer
	Debris:AddItem(respawnTimer, 13)

	monster:Destroy()

	wait(13)
	locator:SetAttribute("InCombat", false)
	for _, waitingLocator: BasePart in waitingLocators do waitingLocator:SetAttribute("InCombat", false) end
end


function ServerUtil:GetPlayersByMonster(monster: Model) : table
	local combatPlrs = {}

	local success = pcall(function()
		for _, target: ObjectValue in monster.TargetPlayers:GetChildren() do
			local tempPlr = Players:GetPlayerFromCharacter(target.Value)

			if tempPlr then insert(combatPlrs, tempPlr) end
		end
	end)

	return if success then combatPlrs else {}
end


function ServerUtil:GenerateOrbPos(monster: Model) : CFrame
	local orbLocation = cfNew(0, 0, 0)

	if not monster then return orbLocation end
	if not monster.PrimaryPart then return orbLocation end

	Promise.new(function(resolve)
		local position = if monster:GetAttribute("SubMonster") then monster.Parent.Parent.Position else monster.Parent.Position
		local ray = rayNew(position, cfNew(position, position + v3New(random(-40, 40), 0, random(-40, 40))).LookVector.Unit * random(5, 40))
		local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, workspace.Monsters:GetDescendants())

		resolve(position, pos)

	end):andThen(function(position: Vector3, pos: Vector3)
		orbLocation = cfNew(pos, pos + cfNew(position).LookVector) * cfNew(0, 7.5, math.random(2, 3))

	end):catch(function(err)
		warn(`[Orb System]: {err}`)
	end)

	return orbLocation
end


function ServerUtil:AddSingleTarget(plr: Player, monster: Model)
	local playerSymbol = instanceNew("ObjectValue")
	playerSymbol.Value = plr.Character
	playerSymbol.Name = plr.Name
	playerSymbol.Parent = monster.TargetPlayers

	local monsterSymbol = instanceNew("ObjectValue")
	monsterSymbol.Value = monster
	monsterSymbol.Name = monster.Name
	monsterSymbol.Parent = plr.Character.CharStats.TargetMonsters
end


function ServerUtil:AddTargetForMonster(plr: Player, monster: Model)
	if not monster then return end
	if not monster.PrimaryPart then return end

	local char = plr.Character

	if not workspace.MapComponents.OrbHolders:FindFirstChild(plr.Name) then
		local folder = instanceNew("Folder")
		folder.Name = plr.Name
		folder:AddTag("OrbHolder")
		folder.Parent = workspace.MapComponents.OrbHolders

		local owner = instanceNew("ObjectValue")
		owner.Name = "Owner"
		owner.Value = char
		owner.Parent = folder
	end

	ServerUtil:AddSingleTarget(plr, monster)

	local mobHighlight = RepS.Package.Effects.EncounterHighlight:Clone() :: Highlight
	mobHighlight.Adornee = monster
	mobHighlight.Parent = monster
	Debris:AddItem(mobHighlight, 2)

	Events.ClientTween.FireAll({ Objs = { mobHighlight }, Goal = { FillTransparency = 1, OutlineTransparency = 1 }, TweenInfo = "one" })

	if not char:GetAttribute("InCombat") then
		char.CharStats.TargetMonster.Value = monster
		char:SetAttribute("InCombat", true)

		local encounterHighlight = RepS.Package.Effects.EncounterHighlight:Clone() :: Highlight
		encounterHighlight.Adornee = char
		encounterHighlight.Parent = char
		Debris:AddItem(encounterHighlight, 2)

		Events.ClientTween.FireAll({ Objs = { encounterHighlight }, Goal = { FillTransparency = 1, OutlineTransparency = 1 }, TweenInfo = "one" })
	end
end


function ServerUtil:ShowNumber(target: Model, number: number, color: Color3?, size: number?)
	--- checks
	if not target then return end
	if not target.PrimaryPart then return end

	local eff = RepS.Package.Effects.Number:Clone() :: Part
	eff.Display.Text.TextColor3 = if color then color else fromRGB(255, 106, 106)
	if size then
		eff.Display.Text.TextScaled = false
		eff.Display.Text.TextSize = size
	else
		eff.Display.Text.TextScaled = true
	end

	eff.Display.Text.Rotation = math.random(-1, 1)
	eff.Display.Text.Text = if number == 0 then "MISS" else number
	eff.CFrame = target.PrimaryPart.CFrame * cfNew(random(-5, 5), random(0, 2), random(-5, 5))
	eff.Parent = workspace

	Debris:AddItem(eff, 2)
end


function ServerUtil:ShowText(char: Model, info: string, color: Color3)
	if not char then return end
	if not char.PrimaryPart then return end

	local eff = RepS.Package.Effects.Text:Clone() :: Part
	eff.Display.Text.Text = info
	eff.Display.Text.TextColor3 = color
	eff.Display.Text.Rotation = math.random(-1, 1)
	eff.CFrame = char.PrimaryPart.CFrame * cfNew(random(-5, 5), random(0, 2), random(-5, 5))
	eff.Parent = workspace

	Debris:AddItem(eff, 2)
end


function ServerUtil:GiveItem(plr: Player, item: string, amount: number)
	local inventoryFolder = plr.Inventory :: Folder
	local isNew = false

	if inventoryFolder:FindFirstChild(item) then
		inventoryFolder[item].Value += amount
		isNew = true

	else
		local itemType = ItemBook:FindItem(item).Type
		local maxAmount = 1

		if itemType == "Active" then if not ItemBook:FindItem(item).IsSkill then maxAmount = 999 end end
		if itemType == "Material" then maxAmount = 999 end

		local intValue = instanceNew("IntConstrainedValue")
		intValue.Name = item
		intValue.MaxValue = maxAmount
		intValue.Value = amount
		intValue.Parent = inventoryFolder
	end

	local itemAcquiredEffect = RepS.Package.Effects.ItemAcquiredEffect:Clone() :: ParticleEmitter
	itemAcquiredEffect.Parent = plr.Character.PrimaryPart
	Debris:AddItem(itemAcquiredEffect, 1)

	Events.GiveDrop.Fire(plr, { ItemId = item, Amount = amount, IsNew = isNew })
end


function ServerUtil:UseSkill(plr: Player, item: string, attributes: table, script: Script) : boolean
	local char = plr.Character
	local monster = char.CharStats.TargetMonster.Value :: Model
	local itemInfo = ItemBook:FindItem(item)

	if attributes.COMBAT_REQ then
		if not char:GetAttribute("InCombat") or not workspace.MapComponents.OrbHolders:FindFirstChild(plr.Name) then
			Events.CreateHint.Fire(plr, { Hint = "You can only use this during combat!" })

			wait()
			script:Destroy()
			return false
		end
	end
	if itemInfo.Mana > 0 then
		if char:GetAttribute("Mana") < itemInfo.Mana then
			Events.CreateHint.Fire(plr, { Hint = "You don't have enough mana!" })

			wait()
			script:Destroy()
			return false
		end

		HarukaLib:AddAttr(char, "Mana", -itemInfo.Mana)
	end
	if attributes.MONSTER_REQ then
		if not monster or not monster.PrimaryPart or not char.PrimaryPart then
			Events.CreateHint.Fire(plr, { Hint = "Target is empty!" })

			wait()
			script:Destroy()
			return false
		end
	end

	Debris:AddItem(script, if attributes.CD then attributes.CD else 5)
	Events.ItemCD.Fire(plr, { Cooldown = if attributes.CD then attributes.CD else 5, ItemId = item })

	local itemSymbol = plr.Inventory[item] :: IntConstrainedValue
	if not ItemBook:FindItem(item).IsSkill then itemSymbol.Value -= 1 end
	if itemSymbol.Value <= 0 then
		Events.EquipItemServer.Fire(plr, { ItemSlot = itemSymbol:GetAttribute("Slot"), ItemId = "Null" })
		itemSymbol:Destroy()
	end

	return true
end


function ServerUtil:FindPartOnRay(givenPos: Vector3, ignoreList: table?) : Vector3
	local ray = rayNew(givenPos, -(yAxis).Unit * 500)
	ignoreList = ignoreList or {}

	while wait() do
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		if hit then
			if not hit.Parent:HasTag("Terrain")
				or not hit.CanCollide
				or hit.Transparency >= 0.5 then

				insert(ignoreList, 1, hit)
			else
				return pos
			end
		else
			return givenPos
		end
	end
end


function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") or object:IsA("UnionOperation") or object:IsA("CornerWedgePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do ServerUtil:SetCollisionGroup(child, group) end
end


function ServerUtil.MobBehaviorTree(monster: Model, funcs: table)
	wait(0.5)
	local success, errorMsg = pcall(function()
		while wait() do
			if not monster.TargetPlayers:FindFirstChildOfClass("ObjectValue") then return end

			local targets = monster.TargetPlayers:GetChildren()
			local target = targets[random(1, #targets)].Value :: Model
			local randomFunc = funcs[random(1, #funcs)]

			local state = randomFunc(target)

			if state == nil then wait(0.5) else wait() end
		end
	end)

	if not success and RS:IsStudio() then warn(errorMsg) end
end


function ServerUtil:GiveBadge(badgeInfo: table, plr: Player, extraFunc: () -> ())
	Spawn(function()
		pcall(function()
			local hasBadgeNew = BadgeService:UserHasBadgeAsync(plr.UserId, badgeInfo[1])
			local hasBadgeOld = true
			if badgeInfo[2] then hasBadgeOld = BadgeService:UserHasBadgeAsync(plr.UserId, badgeInfo[2]) end

			if not hasBadgeNew and hasBadgeOld then
				BadgeService:AwardBadge(plr.UserId, badgeInfo[1])
			end

			if extraFunc then extraFunc() end
		end)
	end)
end


function ServerUtil:SetRole(plr: Player)
	local function _setCustomRole()
		local rank = plr:GetRankInGroup(16912246)
		plr:SetAttribute("Rank", rank)

		if RankBook.RankRoleInfo[rank] then plr:SetAttribute("Role", RankBook.RankRoleInfo[rank].Role) end
		if RankBook.CustomRoleInfo[tostring(plr.UserId)] then plr:SetAttribute("Role", RankBook.CustomRoleInfo[tostring(plr.UserId)].Role) end
	end
	Promise.new(function(resolve)
		local hasBadge = BadgeService:UserHasBadgeAsync(plr.UserId, 2129794607)

		if hasBadge then plr:SetAttribute("Role", "Alpha Tester") end

		resolve()

	end):andThen(_setCustomRole):catch(_setCustomRole)
end

return ServerUtil
