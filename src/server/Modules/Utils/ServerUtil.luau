--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ItemBook = require(RepS.Modules.Data.ItemBook)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local Promise = require(RepS.Modules.Packages.Promise)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local wait = task.wait
local floor, random, rad = math.floor, math.random, math.rad
local cfNew, instanceNew, rayNew, v3New = CFrame.new, Instance.new, Ray.new, Vector3.new
local cfAngles = CFrame.Angles
local fromRGB = Color3.fromRGB
local insert = table.insert
local yAxis = Vector3.yAxis
local sFind = string.find

local ServerUtil = {}

--[[
	SuperWeld actually, a simple function to create weld between two parts
]]
function ServerUtil:WeldPart(part: Part, welded: Model)
	local C = welded:GetChildren()
	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") then
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
		if child:IsA("BasePart") or child:IsA("UnionOperation") then child.Anchored = false end
	end
end

--[[
	Equip player's weapon, you can only pass an class string to force equip
]]
function ServerUtil:EquipWeapon(char: Model, forceClass: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceClass or plr:GetAttribute("Class") :: string
	local styleFolder = RepS.Package.StyleWeapons[class] :: Folder

	for _, child: Instance in char:GetChildren() do
		if sFind(child.Name, "Weapon") then child:Destroy() end
	end

	local function _equipWeapon(weapon: Model, defaultPart: string)
		local weldPos = if weapon:GetAttribute("Position") then weapon:GetAttribute("Position") else defaultPart

		ServerUtil:WeldPart(char[weldPos], weapon)

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

--[[
	Equip cosmetics, just like equip weapons, you can pass a cosmetic to force equip
]]
function ServerUtil:EquipArmor(char: Model, forceArmor: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceArmor or plr:GetAttribute("Class") :: string

    if char.Humanoid.Health > 0 then
        if char:FindFirstChild("Armor") then char.Armor:Destroy() end
		for _, child: Instance in char:GetChildren() do
			if child:HasTag("Weapon") then child:Destroy() end
		end

		local armor = RepS.Package.Armors[class]:Clone() :: Model
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
			ServerUtil:WeldPart(char[part.." Arm"], realWeapon)

			realWeapon:AddTag("Weapon")
			realWeapon.Parent = char
		end
		_weldWeapon("HandleLeft", "Left")
		_weldWeapon("HandleRight", "Right")

		-- equip extra
		if armor:FindFirstChild("Extra") then _equipArmorPart("Extra") end

		armor.Name = "Armor"
        armor.Parent = char
    end
end

--[[
	Spawn a monster, with the given locator part, you can pass level in to force
	Spawn strong monsters
]]
function ServerUtil:SetupMonster(locator: Part, forceLevel: number?) : Model
	if not RepS.Package.MonsterModels:FindFirstChild(locator.Name) then return end

	local level = forceLevel or locator:GetAttribute("Levels") :: number
	local monster = RepS.Package.MonsterModels[locator.Name]:Clone() :: Model
	monster:PivotTo(cfNew(locator.Position) * cfAngles(0, rad(random(1, 360)), 0))
	monster:SetAttribute("Levels", level)

	if not locator:GetAttribute("SubMonster") then
		local tierDisplay = RepS.Package.Effects.TierDisplay:Clone() :: BillboardGui
		tierDisplay.Monster.Text = AssetBook.MonsterInfo[monster.Name].Name
		tierDisplay.Levels.Text = "Level "..level
		tierDisplay.Parent = monster.Head
	else
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("MaxHealth", floor(level ^ 2) + 49)
	monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
	monster:SetAttribute("EXP", (floor(level ^ 1.2) + 25) * if workspace:GetAttribute("2XEXPEvent") then 2 else 1)
	monster:SetAttribute("Damage", 5 * level)
	monster:SetAttribute("InCombat", false)

	local numberDisplay = RepS.Package.Effects.Display:Clone() :: BillboardGui
	numberDisplay.Number.Text = monster:GetAttribute("MaxHealth")
	numberDisplay.Enabled = false
	numberDisplay.Parent = monster.Head

	for _, child: Instance in monster:GetChildren() do
		if child:IsA("Part") and monster:FindFirstChild(child.Name .. "Model") then
			ServerUtil:WeldPart(child, monster[child.Name .. "Model"])
		end
	end
	monster.Parent = locator

	locator.Transparency = 1

	return monster
end

--[[
	Make monster enter combat state from "relax" one
]]
function ServerUtil:MonsterActivateCombat(monster: Model)
	monster:SetAttribute("InCombat", true)
	if not monster:GetAttribute("SubMonster") then monster.Head.TierDisplay.Enabled = false end
	monster.Head.Display.Enabled = true

	local folder = instanceNew("Folder")
	folder.Name = monster.Name
	folder:AddTag("CombatHolder")
	folder.Parent = workspace.MapComponents.CombatFolders

	local owner = instanceNew("ObjectValue")
	owner.Name = "Owner"
	owner.Value = monster
	owner.Parent = folder

	if not monster:GetAttribute("SubMonster") then
		local cageArea = RepS.Package.Unloads.CombatCage:Clone() :: Model
		cageArea:PivotTo(monster.Parent.CFrame)
		cageArea.Owner.Value = monster
		cageArea.Parent = workspace.MapComponents.CageFolders

		monster.CageHolder.Value = cageArea
	else
		monster.CageHolder.Value = monster.Parent.Parent:FindFirstChildOfClass("Model").CageHolder.Value
	end

	monster.AttackHolder.Value = folder
end

--[[
	Monster defeated visual effects, and ready to Spawn another one

	You can make it not respawn after defeated, like story monsters
]]
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

	if monster.CageHolder.Value then monster.CageHolder.Value:Destroy() end

	pcall(function()
		local targetPlrs = ServerUtil:GetPlayersByMonster(monster)
		for _, plr: Player in targetPlrs do
			if not plr then continue end

			Events.FreezePlayerControls:Fire(plr, "Unfreeze")
			Events.CameraPointTo:Fire(plr, "Reset")
		end
	end)

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

	RepS.Resources.Unloads.RespawnCountdown:Clone().Parent = respawnTimer
	Debris:AddItem(respawnTimer, 13)

	monster:Destroy()

	wait(13)
	ServerUtil:SetupMonster(locator)
	for _, waitingLocator: BasePart in waitingLocators do
		ServerUtil:SetupMonster(waitingLocator)
	end
end

--[[
	Get all players that fighting a same monster
]]
function ServerUtil:GetPlayersByMonster(monster: Model) : table
	if not monster then return end
	if not monster:FindFirstChild("TargetPlayers") then return end

	local combatPlrs = {}

	for _, target: ObjectValue in monster.TargetPlayers:GetChildren() do
		local tempPlr = Players:GetPlayerFromCharacter(target.Value)

		if tempPlr then insert(combatPlrs, tempPlr) end
	end

	return combatPlrs
end

--[[
	Find all ignore list when casting rays
]]
function ServerUtil:FindAllIgnoreParts() : table
	local ignore = {}

	for _, child in workspace.Monsters:GetDescendants() do
		if child:HasTag("Monster") then insert(ignore, child) end
	end
	for _, plr in Players:GetPlayers() do
		if plr.Character then insert(ignore, plr.Character) end
	end
	for _, child in workspace.MapComponents.CombatFolders:GetChildren() do
		insert(ignore, child)
	end
	for _, child in workspace.MapComponents.OrbFolders:GetChildren() do
		insert(ignore, child)
	end

	return ignore
end

--[[
	Return a randomly generate a position in the combat area
]]
function ServerUtil:GenerateOrbPos(monster: Model) : CFrame
	local orbLocation: CFrame

	Promise.new(function(resolve)
		local position = if monster:GetAttribute("SubMonster") then monster.Parent.Parent.Position else monster.Parent.Position
		local ray = rayNew(position, cfNew(position, position + v3New(random(-40, 40), 0, random(-40, 40))).LookVector.Unit * random(5, 40))
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ServerUtil:FindAllIgnoreParts())

		resolve(position, pos)

	end):andThen(function(position: Vector3, pos: Vector3)
		orbLocation = cfNew(pos, pos + cfNew(position).LookVector) * cfNew(0, 7, 2)

	end):catch(function()
		orbLocation = cfNew(0, 0, 0)
	end)

	return orbLocation
end

--[[
	Add target for monsters, so that they can attack you
]]
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

--[[
	A list of setups after added targets for monsters
]]
function ServerUtil:AddTargetForMonster(plr: Player, monster: Model)
	if not monster then return end

	local char = plr.Character

	if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then
		local folder = instanceNew("Folder")
		folder.Name = plr.Name
		folder:AddTag("OrbHolder")
		folder.Parent = workspace.MapComponents.OrbFolders

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
		encounterHighlight.Adornee = char
		Debris:AddItem(encounterHighlight, 2)

		Events.ClientTween:Fires({ encounterHighlight }, { FillTransparency = 1, OutlineTransparency = 1 }, "one")
	end
end

--[[
	Pop up the damage you or monster you did in workspace
]]
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

--[[
	Pop up the text which you give, around the part in workspace
]]
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

--[[
	Give drops after monsters are defeated by players
]]
function ServerUtil:GiveDrop(plr: Player, monster: Model)
	local dropChance = LootPlan.new()
	dropChance:Add(monster:GetAttribute("CommonDrop"), 80)
	dropChance:Add(monster:GetAttribute("RareDrop"), 20)

	local drop = dropChance:Roll() :: string

	ServerUtil:GiveItem(plr, drop, 1)

	dropChance:Destroy()
end

--[[
	Give items to player, used by materials or tester commands
]]
function ServerUtil:GiveItem(plr: Player, item: string, amount: number)
	local inventoryFolder = plr.Inventory :: Folder

	if inventoryFolder:FindFirstChild(item) then
		inventoryFolder[item].Value += amount

	else
		local intValue = instanceNew("IntConstrainedValue")
		intValue.Name = item
		intValue.MaxValue = ItemBook:FindItem(item).MaxAmount
		intValue.Value = amount
		intValue.Parent = inventoryFolder
	end

	if not plr.Character.PrimaryPart:FindFirstChild("ItemAcquiredEffect") then
		local itemAcquiredEffect = RepS.Package.Effects.ItemAcquiredEffect:Clone() :: ParticleEmitter
		itemAcquiredEffect.Parent = plr.Character.PrimaryPart
		Debris:AddItem(itemAcquiredEffect, 1)
	end

	Events.GiveDrop:Fire(plr, item)
end

--[[
	A list of checks before using a skill, then we cast it
]]
function ServerUtil:UseSkill(plr: Player, item: string, attributes: table, script: Script) : boolean
	local char = plr.Character
	local monster =  char.CharStats.TargetMonster.Value :: Model

	if attributes.COMBAT_REQ then
		if not char:GetAttribute("InCombat") or not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then
			Events.CreateHint:Fire(plr, "You can only use this during combat!")

			wait()
			script:Destroy()
			return false
		end
	end
	if attributes.TP_REQ then
		if char:GetAttribute("TP") < attributes.TP_REQ then
			Events.CreateHint:Fire(plr, "You don't have enough TP!")

			wait()
			script:Destroy()
			return false
		end

		HarukaLib:Add(char, "TP", -attributes.TP_REQ)
	end
	if attributes.MONSTER_REQ then
		if not monster or not monster.PrimaryPart or not char.PrimaryPart then
			Events.CreateHint:Fire(plr, "Can't find target enemy!")

			wait()
			script:Destroy()
			return false
		end
	end

	Debris:AddItem(script, if attributes.CD then attributes.CD else 8)

	if ItemBook:FindItem(item).IsCM then plr.Inventory[item].Value -= 1 end
	if plr.Inventory[item].Value <= 0 then plr.Inventory[item]:Destroy() end

	return true
end

--[[
	The core function, fires a ray, if there's a part, return the ray position
	where it ends
]]
function ServerUtil:FindPartOnRay(givenPos: Vector3) : Vector3
	local ray = rayNew(givenPos, -(yAxis).Unit * 500)
	local ignoreList = ServerUtil:FindAllIgnoreParts()

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

--[[
	A simple function to set a part's collision group
]]
function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do
		ServerUtil:SetCollisionGroup(child, group)
	end
end

--[[
	Ragdoll an NPC, note that NPC can be player, such as dead ragdoll
]]
function ServerUtil:RagdollNPC(npc: Model)
	if not npc.PrimaryPart then return end

	local ATTACHMENT_CFRAMES = {
		["Neck"] = {
			cfNew(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
			cfNew(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
		},
		["Left Shoulder"] = {
			cfNew(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
			cfNew(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		},
		["Right Shoulder"] = {
			cfNew(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			cfNew(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		},
		["Left Hip"] = {
			cfNew(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			cfNew(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
		["Right Hip"] = {
			cfNew(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			cfNew(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
	}
	npc.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	npc.Torso:ApplyImpulse(npc.Torso.CFrame.LookVector * 100)

	local function _createColliderPart(part: BasePart)
		if not part then return end

		local rp = instanceNew("Part")
		rp.Size = part.Size / 1.7
		rp.Massless = true
		rp.CFrame = part.CFrame
		rp.Transparency = 1

		local wc = instanceNew("WeldConstraint")
		wc.Part0 = rp
		wc.Part1 = part

		wc.Parent = rp
		rp.Parent = part
	end
	for _, child: Instance in npc:GetDescendants() do
		if child:IsA("Motor6D") then
			if not ATTACHMENT_CFRAMES[child.Name] then return end

			child.Enabled = false
			local att0, att1 = instanceNew("Attachment"), instanceNew("Attachment")
			att0.CFrame = ATTACHMENT_CFRAMES[child.Name][1]
			att1.CFrame = ATTACHMENT_CFRAMES[child.Name][2]

			_createColliderPart()

			local bsc = instanceNew("BallSocketConstraint")
			bsc.Attachment0 = att0
			bsc.Attachment1 = att1
			bsc.LimitsEnabled = true
			bsc.TwistLimitsEnabled = if child.Name == "Neck" then true else false
			bsc.Restitution = 0
			bsc.UpperAngle = if child.Name == "Neck" then 45 else 90
			bsc.TwistLowerAngle = if child.Name == "Neck" then -70 else -45
			bsc.TwistUpperAngle = if child.Name == "Neck" then 70 else 45

			att0.Parent = child.Part0
			att1.Parent = child.Part1
			bsc.Parent = child.Parent
		end
	end

	npc.Humanoid.AutoRotate = false
end

--[[
	Cancel the ragdoll after ragdolled, I guess it can't be used on player
]]
function ServerUtil:GettingUpNPC(char: Model)
	if char.Humanoid.Health == 0 then return end

	local ragdollInstanceNames = {
		["RagdollAttachment"] = true,
		["RagdollConstraint"] = true,
		["ColliderPart"] = true,
	}
	for _, child: Instance in char:GetDescendants() do
		if ragdollInstanceNames[child.Name] then child:Destroy() end
		if child:IsA("Motor6D") then child.Enabled = true end
	end

	char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

--[[
	Reward the quest awards
]]
function ServerUtil:GiveQuestRewards(series: string, questId: number, plr: Player)
	for reward: string, val: number in StoryBook[series][questId].Rewards do
		HarukaLib:Add(plr, reward, val)

		ServerUtil:ShowText(plr.Character, "+"..val.." "..reward, fromRGB(212, 255, 0))
	end
end

--[[
	Find the nearest spawn for character
]]
function ServerUtil:FindNearestSpawn(plr: Player) : BasePart
	local char = plr.Character

	local lastLocation = plr:GetAttribute("LastLeave") :: Vector3
	local lastDeath = if lastLocation and lastLocation ~= v3New() then lastLocation else char.PrimaryPart.Position
	local spawnPoint, distance = nil, 9999999999
	for _, child: Instance in workspace.Maps:GetDescendants() do
		if child.Name == "SpawnPoint" then
			local tDistance = (child.Position - lastDeath).Magnitude

			if tDistance < distance then
				distance = tDistance
				spawnPoint = child
			end
		end
	end

	return spawnPoint
end


--[[
	Quickly sort all players, like UIListLayout
]]
function ServerUtil:SortPlayers(players: table, monster: Model, cage: Model)
	for index, plr: Player in players do
		pcall(function()
			local char = plr.Character

			char:PivotTo(cage["Player"..index].CFrame)
			char.Humanoid.AutoRotate = false
			char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.Parent.Position)
		end)
	end
end

--[[
	Quickly sort all monsters
]]
function ServerUtil:SortMonsters(monsters: table, cage: Model)
	for index, monster: Model in monsters do
		pcall(function()
			monster:PivotTo(cage["Monster"..index].CFrame)
		end)
	end
end

return ServerUtil
