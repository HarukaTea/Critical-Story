--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local Promise = require(RepS.Modules.Packages.Promise)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local wait = task.wait
local floor, random, rad = math.floor, math.random, math.rad
local cfNew, instanceNew, rayNew, v3New = CFrame.new, Instance.new, Ray.new, Vector3.new
local cfAngles = CFrame.Angles
local fromRGB = Color3.fromRGB
local insert = table.insert
local yAxis = Vector3.yAxis

local ServerUtil = {}


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
	for _, child in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then child.Anchored = false end
	end
end


function ServerUtil:EquipWeapon(char: Model, forceClass: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceClass or plr:GetAttribute("Class") :: string
	local styleFolder = RepS.Package.StyleWeapons[class] :: Folder

	if char.Humanoid.Health <= 0 then return end
	if plr:GetAttribute("Cosmetic") and plr:GetAttribute("Cosmetic") ~= "None" then return end

	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	local function _equipWeapon(weapon: Model, defaultPart: string)
		local weldPos = if weapon:GetAttribute("Position") then weapon:GetAttribute("Position") else defaultPart

		ServerUtil:WeldModel(char[weldPos], weapon)
		ServerUtil:SetCollisionGroup(weapon, "Player")

		weapon.Parent = char
	end
	if char:GetAttribute("InCombat") == false then --- in case nil
		_equipWeapon(styleFolder.WeaponUnequip:Clone(), "Torso")

		if styleFolder:FindFirstChild("WeaponUnequip2") then _equipWeapon(styleFolder.WeaponUnequip2:Clone(), "Torso") end

	elseif char:GetAttribute("InCombat") then
		_equipWeapon(styleFolder.WeaponEquipped:Clone(), "Right Arm")

        if styleFolder:FindFirstChild("WeaponEquipped2") then _equipWeapon(styleFolder.WeaponEquipped2:Clone(), "Right Arm") end
	end
end


function ServerUtil:EquipArmor(char: Model, armorId: string)
	if char.Humanoid.Health <= 0 then return end

	if char:FindFirstChild("Armor") then char.Armor:Destroy() end

	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	if not armorId or armorId == "" or armorId == "None" then
		ServerUtil:EquipWeapon(char)
		return
	end

	local armor = RepS.Package.Cosmetics[armorId]:Clone() :: Model
	local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

	--- wait character fully loads
	for _, part: string in equipList do char:WaitForChild(part, 999) end

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

	-- equip extra
	if armor:FindFirstChild("Extra") then _equipArmorPart("Extra") end

	--- ray cancels
	ServerUtil:SetCollisionGroup(armor, "Player")

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
		tierDisplay.Monster.Text = AssetBook.MonsterInfo[monster.Name].Name
		tierDisplay.Levels.Text = "Level "..level
		tierDisplay.Parent = monster.Head

		tierDisplay.Enabled = if monster:GetAttribute("HideTag") then false else true
	else
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("MaxHealth", floor(level ^ 2.3) + 39)
	monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
	monster:SetAttribute("EXP", (floor(level ^ 1.45) + 29))
	monster:SetAttribute("Damage", (floor(level ^ 1.4) + 4))
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
	local orbLocation: CFrame

	Promise.new(function(resolve)
		local position = if monster:GetAttribute("SubMonster") then monster.Parent.Parent.Position else monster.Parent.Position
		local ray = rayNew(position, cfNew(position, position + v3New(random(-40, 40), 0, random(-40, 40))).LookVector.Unit * random(5, 40))
		local hit, pos = workspace:FindPartOnRay(ray)

		resolve(position, pos)

	end):Then(function(position: Vector3, pos: Vector3)
		orbLocation = cfNew(pos, pos + cfNew(position).LookVector) * cfNew(0, 9, 2)

	end):Catch(function(err)
		orbLocation = cfNew(0, 0, 0)

		warn("[Orb System]: "..err)
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

	if not char:GetAttribute("InCombat") then
		char.CharStats.TargetMonster.Value = monster
		char:SetAttribute("InCombat", true)

		local encounterHighlight = RepS.Package.Effects.EncounterHighlight:Clone() :: Highlight
		encounterHighlight.Parent = char
		Debris:AddItem(encounterHighlight, 2)

		Events.ClientTween:FireAll({ encounterHighlight }, { FillTransparency = 1, OutlineTransparency = 1 }, "one")
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

	eff.Display.Text.Text = if number == 0 then "Miss" else number
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
	eff.CFrame = char.PrimaryPart.CFrame * cfNew(random(-5, 5), random(0, 2), random(-5, 5))
	eff.Parent = workspace

	Debris:AddItem(eff, 2)
end


function ServerUtil:GiveItem(plr: Player, item: string, amount: number)
	local inventoryFolder = plr.Inventory :: Folder

	if inventoryFolder:FindFirstChild(item) then
		inventoryFolder[item].Value += amount

	else
		local intValue = instanceNew("IntConstrainedValue")
		intValue.Name = item
		intValue.MaxValue = if ItemBook:FindItem(item).IsSkill then 1 else 999
		intValue.Value = amount
		intValue.Parent = inventoryFolder
	end

	local itemAcquiredEffect = RepS.Package.Effects.ItemAcquiredEffect:Clone() :: BasePart
	itemAcquiredEffect.CFrame = plr.Character.PrimaryPart.CFrame
	itemAcquiredEffect.Parent = workspace
	Debris:AddItem(itemAcquiredEffect, 1)

	Events.GiveDrop:Fire(plr, item)
end


function ServerUtil:UseSkill(plr: Player, item: string, attributes: table, script: Script) : boolean
	local char = plr.Character
	local monster = char.CharStats.TargetMonster.Value :: Model
	local itemInfo = ItemBook:FindItem(item)

	if attributes.COMBAT_REQ then
		if not char:GetAttribute("InCombat") or not workspace.MapComponents.OrbHolders:FindFirstChild(plr.Name) then
			Events.CreateHint:Fire(plr, "You can only use this during combat!")

			wait()
			script:Destroy()
			return false
		end
	end
	if itemInfo.Mana > 0 then
		if char:GetAttribute("Mana") < itemInfo.Mana then
			Events.CreateHint:Fire(plr, "You don't have enough Mana!")

			wait()
			script:Destroy()
			return false
		end

		HarukaLib:AddAttr(char, "Mana", -itemInfo.Mana)
	end
	if attributes.MONSTER_REQ then
		if not monster or not monster.PrimaryPart or not char.PrimaryPart then
			Events.CreateHint:Fire(plr, "Can't find target enemy!")

			wait()
			script:Destroy()
			return false
		end
	end

	Debris:AddItem(script, if attributes.CD then attributes.CD else 5)
	Events.ItemCD:Fire(plr, if attributes.CD then attributes.CD else 5, item)

	local itemSymbol = plr.Inventory[item] :: IntConstrainedValue
	if not ItemBook:FindItem(item).IsSkill then itemSymbol.Value -= 1 end
	if itemSymbol.Value <= 0 then
		Events.EquipItems:Fire(plr, itemSymbol:GetAttribute("Slot"), "Null")
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
			if not (hit.Parent:HasTag("Terrain") or hit.Parent.Name == "Terrain")
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


function ServerUtil:GiveQuestRewards(series: string, questId: number, plr: Player)
	for reward: string, val: number in StoryBook[series][questId].Rewards do
		HarukaLib:AddAttr(plr, reward, val)

		ServerUtil:ShowText(plr.Character, "+"..val.." "..reward, fromRGB(212, 255, 0))
	end
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

return ServerUtil
