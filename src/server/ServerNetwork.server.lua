--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")

local CSAttackUtil = require(SSS.Modules.Utils.CSAttackUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local FastSpawn = require(RepS.Modules.Packages.Spawn)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local PassiveUtil = require(SSS.Modules.Utils.PassiveUtil)

local floor = math.floor
local fromRGB = Color3.fromRGB
local delay = task.delay
local insert = table.insert
local instanceNew = Instance.new

--[[
	Combat starts! Good luck players
]]
local function combatStartSetup(plr: Player, monster: Model, mode: string)

	--- if monster was occupied by another player, you wanna join it
	if monster:GetAttribute("InCombat") then
		ServerUtil:AddTargetForMonster(plr, monster)
		return
	end

	ServerUtil:AddTargetForMonster(plr, monster)
	ServerUtil:MonsterActivateCombat(monster, mode, plr)

	--- sub-monster exist
	if monster.Parent:FindFirstChildOfClass("Part") then
		for _, subMonster in monster.Parent:GetDescendants() do
			if subMonster:GetAttribute("IsMonster") and subMonster:GetAttribute("SubMonster") then
				ServerUtil:AddTargetForMonster(plr, subMonster)

				if not subMonster:GetAttribute("InCombat") then
					ServerUtil:MonsterActivateCombat(subMonster)
				end
			end
		end
	end
end

--[[
	Combat ends, we don't know whether it's success or not
]]
local function combatEndSetup(monster: Model)
	monster.Attack.Disabled = true

	local attackFolder = monster.Holder.Value
	local continueCombatCheck = false
	local result = if monster:GetAttribute("Health") <= 0 then "Success" else "Failed"

	delay(1, function()
		attackFolder:Destroy()
	end)

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
		for _, attack in attackFolder:GetDescendants() do
			if attack:IsA("BasePart") then
				if attack.Transparency < 1 then insert(attacks, attack) end
			end
			attack:SetAttribute("IsDamage", nil)
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
				ServerUtil:EquipWeapon(player.Character)

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

		--- tricky this time, may think a better choice in the future
		for _, child in workspace.Monsters:GetDescendants() do
			if child:GetAttribute("IsMonster")
				and child ~= monster
				and child:GetAttribute("InCombat")
				and child:GetAttribute("Health") > 0 then

				if (monster.PrimaryPart.Position - child.PrimaryPart.Position).Magnitude <= 128 then
					continueCombatCheck = true

					local locator = instanceNew("ObjectValue")
					locator.Name = monster.Name
					locator.Value = monster.Parent
					locator:SetAttribute("EXP", monster:GetAttribute("EXP"))
					locator.Parent = child.WaitingList

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
Events.CombatStart:Connect(combatStartSetup)
Signals.CombatEnd:Connect(function(monster: Model)
	--- I have no idea why this can be broken without task.spawn
	FastSpawn(combatEndSetup, monster)
end)

--[[
	Player send request to cast unique skills of their classes
]]
local function castCSSkills(plr: Player)
	local class = plr:GetAttribute("Class")
	local char = plr.Character

	if CSAttackUtil[class] then CSAttackUtil[class](char) end
end
Events.CastClassSkill:Connect(castCSSkills)

--[[
	Player finally reach the requirement and level up!
]]
local LEVEL_CAP = 125
local LEVEL_POINT = 2
local function expCheck(exp: number, level: number) : boolean
	if exp >= floor(level ^ 1.85) + 60 and level < LEVEL_CAP then
		return true
	else
		return false
	end
end
local function levelUp(plr: Player)
	local check = expCheck(plr:GetAttribute("EXP"), plr:GetAttribute("Levels"))

	if check then
		HarukaLib:Add(plr, "Levels", 1)
		HarukaLib:Add(plr, "EXP", -(floor((plr:GetAttribute("Levels") - 1) ^ 1.85) + 60))
		HarukaLib:Add(plr, "LvPoints", LEVEL_POINT)

		if expCheck(plr:GetAttribute("EXP"), plr:GetAttribute("Levels")) then levelUp(plr) return end

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.LevelUp)
		Events.LevelUp:Fire(plr)

		ServerUtil:ShowText(plr.Character, "LEVEL UP!", fromRGB(255, 255, 0))

	elseif not check and plr:GetAttribute("Levels") < LEVEL_CAP then
		plr:SetAttribute("Levels", LEVEL_CAP)
		plr:SetAttribute("EXP", 0)
	end

	--- to avoid bypass actually...
	if plr:GetAttribute("Levels") > LEVEL_CAP then
		plr:SetAttribute("Levels", LEVEL_CAP)
		plr:SetAttribute("EXP", 0)
	end
end
Signals.LevelUp:Connect(levelUp)

--[[
	Handle the request from player to add points
]]
local function addPoint(plr: Player, option: string, times: number)
	if option == "Reset" then
		local cost = ((plr:GetAttribute("Levels") - 1) * LEVEL_POINT - plr:GetAttribute("LvPoints")) * 20

		if plr:GetAttribute("Gold") < cost then
			Events.CreateHint:Fire(plr, "You don't have enough Gold to reset!")
			return
		end

		HarukaLib:Add(plr, "Gold", -cost)
		plr:SetAttribute("DmgPoints", 0)
		plr:SetAttribute("MagicPoints", 0)
		plr:SetAttribute("ManaPoints", 0)
		plr:SetAttribute("HealthPoints", 0)
		plr:SetAttribute("ShieldPoints", 0)
		plr:SetAttribute("LvPoints", (plr:GetAttribute("Levels") - 1) * LEVEL_POINT)
		return
	end

	if plr:GetAttribute("LvPoints") > 0 then
		for i = 1, times do
			if plr:GetAttribute("LvPoints") > 0 then
				HarukaLib:Add(plr, option, 1)
				HarukaLib:Add(plr, "LvPoints", -1)
			end
		end
	end
end
Events.AddPoints:Connect(addPoint)

--[[
	Handle the request from player to equip an item
]]
local function equipNewItem(plr: Player, item: string, slot: string)
	local inventory = plr.Inventory

	if not inventory:FindFirstChild(item) then return end
	if inventory[item]:GetAttribute("Equipped") then return end

	inventory[item]:SetAttribute("Equipped", true)
	inventory[item]:SetAttribute("Slot", slot)

	Signals.ItemsEquipped:Fire(plr)
	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Equip)
end
local function unequipCheck(plr: Player, item: string)
	local inventory = plr.Inventory

	if inventory:FindFirstChild(item) then
		inventory[item]:SetAttribute("Equipped", nil)
		inventory[item]:SetAttribute("Slot", nil)
	end

	Signals.ItemsEquipped:Fire(plr)
end
local function equipItem(plr: Player, itemType: string, itemSlot: string, item: string)
	local char = plr.Character

	if itemType == "Active" then
		equipNewItem(plr, item, itemSlot)

		Events.RefreshBackpack:Fire(plr)
		Events.EquipItems:Fire(plr, itemType, itemSlot, item)

	elseif itemType == "Passive" then
		if not char.CharStats.Items:GetAttribute(item) then
			PassiveUtil:EquipPassive(item, char)
		end
		equipNewItem(plr, item, itemSlot)

		Events.RefreshBackpack:Fire(plr)
		Events.EquipItems:Fire(plr, itemType, itemSlot, item)

	elseif itemType == "Cosmetic" then
		plr:SetAttribute("CosmeticArmor", item)
		ServerUtil:EquipCosmetics(char)

		equipNewItem(plr, item, itemSlot)

		Events.RefreshBackpack:Fire(plr)

	elseif itemType == "ClearPassive" and item ~= "" then
		char.CharStats.Items:SetAttribute(item.."_PASSIVE", false)
		PassiveUtil:ClearAllPassives(char)

		unequipCheck(plr, item)

		Events.RefreshBackpack:Fire(plr)
		Signals.ItemsEquipped:Fire(plr)

	elseif itemType == "ClearActive" and item ~= "" then
		unequipCheck(plr, item)

		Events.RefreshBackpack:Fire(plr, item)
		Events.ItemCD:Fire(plr, 0, itemSlot)
		Signals.ItemsEquipped:Fire(plr)

	elseif itemType == "ClearCosmetic" and item ~= "" then
		if char:FindFirstChild("Armor") then char.Armor:Destroy() end
		unequipCheck(plr, item)

		plr:SetAttribute("Cosmetic", "None")

		Events.RefreshBackpack:Fire(plr)
		Signals.ItemsEquipped:Fire(plr)
	end
end
Events.EquipItems:Connect(equipItem)

--[[
	Handle the request from player to use items
]]
local function essentialCheck(plr: Player, item: string) : string
	if
		plr.Inventory:FindFirstChild(item)
		and plr.Inventory[item].Value > 0
		and plr.Inventory[item]:GetAttribute("Equipped")
	then
		return "Exist"
	else
		return "None"
	end
end
local function useItem(plr: Player, item: string)
	if RepS.Resources.Items:FindFirstChild(item) and essentialCheck(plr, item) == "Exist" then
		if plr.Character.CharStats.Items:FindFirstChild(item) then return end

		RepS.Resources.Items[item]:Clone().Parent = plr.Character.CharStats.Items
	end
end
Events.UseItem:Connect(useItem)

--[[
	Handle the request from player to pin an item
]]
local function pinItem(plr: Player, item: string)
	if not plr.Inventory:FindFirstChild(item) then return end

	local realItem = plr.Inventory[item] :: IntValue

	if realItem:GetAttribute("Pinned") then
		realItem:SetAttribute("Pinned", nil)
	else
		realItem:SetAttribute("Pinned", true)
	end

	Signals.ItemsPinned:Fire(plr)
end
Events.UpdatePinnedItems:Connect(pinItem)

--[[
	Sometimes datastore can be easily down, and that will crash the game
]]
local function dataStoreErrorKick(plr: Player)
	plr:Kick("Rblx datastore may be down currently, rejoin to try again!")
end
Events.ErrorDataStore:Connect(dataStoreErrorKick)

--[[
	Sometimes player wanna rejoin by typing `!rejoin` in chat
]]
local function rejoinRequest(plr: Player)
	TeleS:Teleport(game.PlaceId, plr)
end
Events.RejoinRequest:Connect(rejoinRequest)

--- Start the server after net listening are all done
require(script.Parent.Modules.ServerSetups)()
