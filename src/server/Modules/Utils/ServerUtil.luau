--!strict

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local Signals = require(SSS.Modules.Data.ServerSignals)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
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
function ServerUtil:WeldPart(part: Part, welded: Model, style: string?)
	local finalWeld = if style == "Orb" then welded.Base else welded.Middle

	local C = welded:GetChildren()
	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") then
			local W = instanceNew("Weld")
			W.Part0 = finalWeld
			W.Part1 = C[i]
			local CJ = cfNew(finalWeld.Position)
			W.C0 = finalWeld.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = finalWeld
		end
		local Y = instanceNew("Weld")
		Y.Part0 = part
		Y.Part1 = finalWeld
		Y.C0 = cfNew(v3New())
		Y.Parent = Y.Part0
	end
	local h = welded:GetChildren()
	for _, child in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") then
			child.Anchored = false
		end
	end
end

--[[
	Equip player's weapon, you can only pass an class string to force equip
]]
function ServerUtil:EquipWeapon(char: Model, forceClass: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceClass or plr:GetAttribute("Class")

	for _, child in char:GetChildren() do
		if sFind(child.Name, "Weapon") then child:Destroy() end
	end

	if char:GetAttribute("InCombat") == false then
		if class == "Alchemist" then
			local model = RepS.Package.StyleWeapons.Alchemist.WeaponEquipped:Clone() :: Model
			local model2 = RepS.Package.StyleWeapons.Alchemist.WeaponEquipped2:Clone() :: Model

			ServerUtil:WeldPart(char["Right Arm"], model)
			ServerUtil:WeldPart(char["Left Arm"], model2)

			model.Parent = char
			model2.Parent = char
		else
			local model = RepS.Package.StyleWeapons[class].WeaponUnequip:Clone() :: Model

			ServerUtil:WeldPart(char.Torso, model)

			model.Parent = char
		end

	elseif char:GetAttribute("InCombat") then
		local weapon = RepS.Package.StyleWeapons[class].WeaponEquipped:Clone() :: Model

        ServerUtil:WeldPart(char["Right Arm"], weapon)
        weapon.Parent = char

        if class == "Repeater" or class == "Alchemist" then
            local weapon2 = RepS.Package.StyleWeapons[class].WeaponEquipped2:Clone() :: Model
            ServerUtil:WeldPart(char["Left Arm"], weapon2)

            weapon2.Parent = char
        end
	end
end

--[[
	Equip cosmetics, just like equip weapons, you can pass a cosmetic to force equip
]]
function ServerUtil:EquipCosmetics(char: Model, forceCosmetic: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local cosmetic = forceCosmetic or plr:GetAttribute("Cosmetic")

    if char.Humanoid.Health > 0 then
        if char:FindFirstChild("Armor") then char.Armor:Destroy() end
		for _, child in char:GetChildren() do
			if child:GetAttribute("Weapon") then child:Destroy() end
		end

		local armor = RepS.Package.Items.Cosmetics[cosmetic]:Clone() :: Model
        local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

        --- wait character fully loads
        for _, part in equipList do char:WaitForChild(part, 999) end

		--- equip armor
        for _, part in equipList do
            for _, child in armor[part]:GetChildren() do
                if child.Name ~= "Middle" then
                    local weldC = instanceNew("WeldConstraint")
                    weldC.Part0 = child.Parent.Middle
                    weldC.Part1 = child
                    weldC.Parent = armor
                end
            end

            local weld = instanceNew("Weld")
            weld.Part0 = char:FindFirstChild(part)
            weld.Part1 = armor[part].Middle
            weld.Parent = armor
        end

        armor.Name = "Armor"
        armor.Parent = char

		local leftWeapon = armor.WeaponLeft:Clone() :: Model
		local rightWeapon = armor.WeaponRight:Clone() :: Model

		ServerUtil:WeldPart(char["Left Arm"], leftWeapon)
		ServerUtil:WeldPart(char["Right Arm"], rightWeapon)

		leftWeapon.Parent = char
		rightWeapon.Parent = char
    end
end

--[[
	Spawn a monster, with the given locator part, you can pass level in to force
	Spawn strong monsters
]]
function ServerUtil:SetupMonster(locator: Part, forceLevel: number?) : Model
	if not RepS.Package.MonsterModels:FindFirstChild(locator.Name) then return end

	local level = forceLevel or locator:GetAttribute("Levels")
	local monster = RepS.Package.MonsterModels[locator.Name]:Clone() :: Model
	monster:PivotTo(cfNew(locator.Position) * cfAngles(0, rad(random(1, 360)), 0))
	monster:SetAttribute("Levels", level)
	monster.Head.TierDisplay.Text.Text = monster.Name
	monster.Head.TierDisplay.Level.Text = "Level " .. level
	monster.Head.TierDisplay.Enabled = true

	if locator:GetAttribute("SubMonster") then
		monster.Head.TierDisplay.Enabled = false
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("MaxHealth", floor(level ^ 2.2) + 99)
	monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
	monster:SetAttribute("EXP", (floor(level ^ 1.25) + 25) * if workspace:GetAttribute("2XEXPEvent") then 2 else 1)
	monster:SetAttribute("Damage", 5 * level)
	monster:SetAttribute("InCombat", false)

	for _, child in monster:GetChildren() do
		if child:IsA("Part") and monster:FindFirstChild(child.Name .. "Model") then
			ServerUtil:WeldPart(child, monster[child.Name .. "Model"])
		end
	end
	local monsterHPScript = RepS.Resources.Unloads.MonsterHP:Clone() :: Script
	monsterHPScript.Disabled = true
	monsterHPScript.Parent = monster

	monster.Parent = locator

	locator.Transparency = 1

	return monster
end

--[[
	Make monster enter combat state from "relax" one
]]
function ServerUtil:MonsterActivateCombat(monster: Model, mode: string?, plr: Player?)
	monster:SetAttribute("InCombat", true)
	monster.Head.TierDisplay.Enabled = false
	monster.Head.Display.Enabled = true
	monster.Head.Display.Number.Text = monster:GetAttribute("MaxHealth")

	local folder = instanceNew("Folder")
	folder.Name = monster.Name
	if mode then folder:SetAttribute(mode.."Combat", true) end
	folder:AddTag("CombatHolder")
	folder.Parent = workspace.MapComponents.CombatFolders

	local owner = instanceNew("ObjectValue")
	owner.Name = "Owner"
	owner.Value = monster
	owner.Parent = folder

	monster.Holder.Value = folder
	monster.MonsterHP.Disabled = false
	monster.Attack.Disabled = false

	if monster:GetAttribute("SubMonster") then return end

	if mode == "Public" then
		local locator = monster.Parent

		local joinPrompt = RepS.Package.Unloads.PublicJoinPrompt:Clone() :: Part
		joinPrompt.CFrame = cfNew(locator.Position) * cfNew(0, 4, 0)

		local prompt = joinPrompt.PublicJoin :: ProximityPrompt
		prompt:SetAttribute("Owner", plr.Name)
		prompt:AddTag("CombatJoinPrompt")

		joinPrompt.Parent = locator

	elseif mode == "Party" then
		local locator = monster.Parent

		local joinPrompt = RepS.Package.Unloads.PublicJoinPrompt:Clone() :: Part
		joinPrompt.CFrame = cfNew(locator.Position) * cfNew(0, 4, 0)

		local prompt = joinPrompt.PublicJoin :: ProximityPrompt
		prompt:SetAttribute("Owner", plr.Name)
		prompt.Name = "PartyJoin"
		prompt:AddTag("CombatJoinPrompt")

		joinPrompt.Parent = locator
	end
end

--[[
	Monster defeated visual effects, and ready to Spawn another one

	You can make it not respawn after defeated, like story monsters
]]
function ServerUtil:MonsterDefeated(monster: Model, deadPos: Vector3, allowRespawn: boolean?)
	local respawnLocatorTip = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent
	local locator = monster.Parent

	wait(1)
	if monster.Holder.Value then monster.Holder.Value:Destroy() end

	local defeatedEffect = RepS.Package.Effects.DefeatedEffect:Clone() :: Part
	defeatedEffect.Position = deadPos
	defeatedEffect.Parent = workspace

	Debris:AddItem(defeatedEffect, 1)

	Spawn(function()
		wait(0.3)
		defeatedEffect.Particle.Enabled = false
	end)

	if not allowRespawn or locator:GetAttribute("CantRespawn") then
		monster:Destroy()
		return
	end

	--- multi-combat mechanic
	local waitingLocators = {}
	if monster.WaitingList:FindFirstChildOfClass("ObjectValue") then
		for _, waitingMonster in monster.WaitingList:GetChildren() do
			insert(waitingLocators, waitingMonster.Value)
		end
	end
	local respawnTimer = RepS.Package.Unloads.RespawnTimer:Clone() :: Part
	respawnTimer.Position = respawnLocatorTip.Position
	respawnTimer.Parent = workspace

	RepS.Resources.Unloads.RespawnCountdown:Clone().Parent = respawnTimer
	Debris:AddItem(respawnTimer, 13)

	monster:Destroy()
	if respawnLocatorTip:FindFirstChild("PublicJoinPrompt") then respawnLocatorTip.PublicJoinPrompt:Destroy() end
	if respawnLocatorTip:FindFirstChild("PartyJoinPrompt") then respawnLocatorTip.PartyJoinPrompt:Destroy() end

	wait(13)
	ServerUtil:SetupMonster(locator)
	for _, waitingLocator in waitingLocators do
		ServerUtil:SetupMonster(waitingLocator)
	end
end

--[[
	Return a randomly generate a position in the combat area
]]
function ServerUtil:GenerateOrbPos(monster: Model) : CFrame
	--- checks
	local check = true

	Spawn(function()
		if not monster then check = false end
		if not monster.Parent then check = false end
		if not monster.Parent.Parent then check = false end
	end)
	if not check then return cfNew(0, 0, 0) end

	local ignore = {}
	for _, child in workspace.Monsters:GetDescendants() do
		if child:HasTag("Monster") then insert(ignore, child) end
	end
	for _, plr in Players:GetPlayers() do
		if plr.Character then insert(ignore, plr.Character) end
	end
	for _, child in workspace.MapComponents.CombatFolders:GetChildren() do
		if child:HasTag("CombatHolder") then insert(ignore, child) end
	end

	local position = if monster:GetAttribute("SubMonster") then monster.Parent.Parent.Position else monster.Parent.Position
	local ray = rayNew(
		position,
		cfNew(position, position + v3New(random(-40, 40), 0, random(-40, 40))).LookVector.Unit * random(5, 40))
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignore)

	return cfNew(pos, pos + cfNew(position).LookVector) * cfNew(0, 7, 2)
end

--[[
	Add target for monsters, so that they can attack you
]]
function ServerUtil:AddSingleTarget(plr: Player, monster: Model)
	local playerSymbol = instanceNew("ObjectValue")
	playerSymbol.Value = plr.Character
	playerSymbol.Name = plr.Name
	playerSymbol.Parent = monster.TargetingList

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

		Spawn(function()
			wait(1)
			Events.ClientTween:Fires({ encounterHighlight }, { FillTransparency = 1, OutlineTransparency = 1 }, "one")
		end)
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
	eff.CFrame = target.PrimaryPart.CFrame * cfNew(random(-5, 5), random(0, 4), random(-5, 5))
	eff.Parent = workspace

	Debris:AddItem(eff, 2)
end

--[[
	Pop up the text which you give, around the part in workspace
]]
function ServerUtil:ShowText(char: Model, info: string, color: Color3)
	local eff = RepS.Package.Effects.Text:Clone() :: Part
	eff.Display.Text.Text = info
	eff.Display.Text.TextColor3 = color
	eff.CFrame = char.PrimaryPart.CFrame * cfNew(0, random(-5, 5), 0)
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
	local inventoryFolder = plr.Inventory

	if inventoryFolder:FindFirstChild(item) then
		inventoryFolder[item].Value += amount

	else
		local itemType = AssetBook.Items.ItemType[item]

		if not AssetBook.Items.IsSkill[item] and (itemType == "Active" or itemType == "Material") then
			local intValue = instanceNew("IntConstrainedValue")
			intValue.Name = item
			intValue.MaxValue = 9999
			intValue.Value = amount
			intValue.Parent = inventoryFolder

		else
			local intValue = instanceNew("IntConstrainedValue")
			intValue.Name = item
			intValue.MaxValue = 1
			intValue.Value = amount
			intValue.Parent = inventoryFolder
		end
	end

	Events.GiveDrop:Fire(plr, item)
	Events.RefreshBackpack:Fire(plr)
end

--[[
	Refresh the AdventureStats UI, though the name is RefreshBackpack lol
]]
function ServerUtil:RefreshBackpack(plr: Player, item: string, cd: number, isSkill: boolean?)
	if not isSkill then plr.Inventory[item].Value -= 1 end

	Events.ItemCD:Fire(plr, cd, item)
	Events.RefreshBackpack:Fire(plr)

	if plr.Inventory[item].Value == 0 then
		plr.Inventory[item]:Destroy()

		Events.ItemCD:Fire(plr, 0, item)
		Events.RefreshBackpack:Fire(plr)
	end
end

--[[
	A list of checks before using a skill, then we cast it
]]
function ServerUtil:UseSkill(plr: Player, item: string, attributes: table, script: Script, classUnique: boolean?) : boolean
	local char = plr.Character
	local monster =  char.CharStats.TargetMonster.Value :: Model

	if attributes.COMBAT_REQ then
		if not char:GetAttribute("InCombat") or not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then
			Events.CreateHint:Fire(plr, "You can only use this during combat!", "Error")

			wait()
			script:Destroy()
			return false
		end
	end
	if attributes.MANA_REQ then
		if SkillUtil:ManaCheck(plr, attributes.MANA_REQ) == false then
			Events.CreateHint:Fire(plr, "You don't have enough Mana!", "Error")

			wait()
			script:Destroy()
			return false
		end
	end
	if attributes.MONSTER_REQ then
		if not monster or not monster.PrimaryPart or not char.PrimaryPart then
			wait()
			script:Destroy()
			return false
		end
	end

	Debris:AddItem(script, attributes.CD)

	if not classUnique then
		ServerUtil:RefreshBackpack(plr, item, attributes.CD, if AssetBook.Items.IsSkill[item] then true else false)
	end

	return true
end

--[[
	The core function, fires a ray, if there's a part, return the ray position
	where it ends
]]
function ServerUtil:FindPartOnRay(givenPos: Vector3, ignores: table?) : Vector3
	local ray = rayNew(givenPos, -(yAxis).Unit * 500)
	local ignoreList = ignores or {}

	while wait() do
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		if hit then
			if not (hit.Parent:HasTag("Terrain") or hit.Parent.Name == "Terrain")
				or not hit.CanCollide
				or hit.Transparency >= 0.5 then

				insert(ignoreList, hit)
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
	if object:IsA("BasePart") then
		object.CollisionGroup = group
	end

	for _, child in object:GetChildren() do
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
	for _, child in npc:GetDescendants() do
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
	for _, child in char:GetDescendants() do
		if ragdollInstanceNames[child.Name] then child:Destroy() end
		if child:IsA("Motor6D") then child.Enabled = true end
	end

	char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

--[[
	Reward the quest awards
]]
function ServerUtil:GiveQuestRewards(series: string, questId: number, plr: Player)
	for reward, val in StoryBook[series][questId].Rewards do
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
	for _, child in workspace.Maps:GetDescendants() do
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
	Connects to an exist mob when combat ends
]]
function ServerUtil:ConnectMob(locator: BasePart)
	local function combatEnds()
		local monster = locator:FindFirstChildOfClass("Model")

		monster.Attack.Disabled = true

		local attackFolder = monster.Holder.Value
		local continueCombatCheck = false

		--- another issue, don't change this else it will bug
		local result = "Failed"
		if monster:GetAttribute("Health") <= 0 then result = "Success" end

		if result == "Failed" then
			ServerUtil:MonsterDefeated(monster, monster.PrimaryPart.Position, true)
			return
		end

		if result == "Success" then
			local combatPlrs, attacks = {}, {}
			for _, target in monster.TargetingList:GetChildren() do
				local tempPlr = Players:GetPlayerFromCharacter(target.Value)

				if tempPlr then insert(combatPlrs, tempPlr) end
			end
			for _, attack: Instance in attackFolder:GetDescendants() do
				if attack:IsA("BasePart") then
					if attack.Transparency < 1 then insert(attacks, attack) end
				end
				attack:RemoveTag("MonsterDMG")
			end
			for _, player in combatPlrs do
				Events.ClientTween:Fire(player, attacks, { Transparency = 1 }, "one")
			end

			for _, player in combatPlrs do
				local charStats = player.Character.CharStats

				--- player finished combat
				if not charStats.TargetMonsters:FindFirstChildOfClass("ObjectValue") then
					local beatList = { monster }
					for _, otherMonster in monster.WaitingList:GetChildren() do
						insert(beatList, otherMonster)
					end

					local totalEXP = 0
					for _, defeated in beatList do
						totalEXP += defeated:GetAttribute("EXP")

						ServerUtil:GiveDrop(player, RepS.Package.MonsterModels[defeated.Name])
					end

					HarukaLib:Add(player, "EXP", totalEXP)
					HarukaLib:Add(player, "Gold", floor(totalEXP / 1.5))
					HarukaLib:Add(player, "RP", floor(totalEXP / 5))

					ServerUtil:ShowText(player.Character, "+" .. totalEXP .. " EXP", fromRGB(245, 205, 48))
					ServerUtil:ShowText(player.Character, "+" .. floor(totalEXP / 1.5) .. " Gold", fromRGB(255, 255, 127))
					ServerUtil:ShowText(player.Character, "+" .. floor(totalEXP / 5) .. " RP", fromRGB(0, 255, 255))

					player.Character:SetAttribute("InCombat", false)
					charStats.TargetMonster.Value = nil

					for _, orbFolder in workspace.MapComponents.OrbFolders:GetChildren() do
						if orbFolder.Name == player.Name then orbFolder:Destroy() end
					end

					continue
				end

				--- if still doesn't finished, then target next one
				charStats.TargetMonster.Value = charStats.TargetMonsters:FindFirstChildOfClass("ObjectValue").Value
			end

			local locator = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent
			for _, child in locator:GetDescendants() do
				if child:HasTag("Monster")
					and child ~= monster
					and child:GetAttribute("InCombat") == true
					and child:GetAttribute("Health") > 0 then

					if child:FindFirstChild("TargetingList") and
						child.TargetingList:FindFirstChildOfClass("ObjectValue") then

						continueCombatCheck = true

						local locatorSymbol = instanceNew("ObjectValue")
						locatorSymbol.Name = monster.Name
						locatorSymbol.Value = monster.Parent
						locatorSymbol:SetAttribute("EXP", monster:GetAttribute("EXP"))
						locatorSymbol.Parent = child.WaitingList

						for _, pastWaiting in monster.WaitingList:GetChildren() do
							pastWaiting.Parent = child.WaitingList
						end
						break
					end
				end
			end

			ServerUtil:MonsterDefeated(monster, monster.PrimaryPart.Position, not continueCombatCheck)
		end
	end
	locator.CombatEnd.Event:Connect(combatEnds)
end

return ServerUtil
