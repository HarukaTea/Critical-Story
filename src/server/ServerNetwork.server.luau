--!nocheck

local Players = game:GetService("Players")
local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")
local TestS = game:GetService("TestService")

local AttackUtil = require(SSS.Modules.Utils.AttackUtil)
local DialogueBook = require(RepS.Modules.Data.DialogueBook)
local Events = require(SSS.Modules.Data.ServerEvents)
local LootPlan = require(RepS.Modules.Packages.LootPlan)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Signals = require(SSS.Modules.Data.ServerSignals)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)
local StoryBook = require(RepS.Modules.Data.StoryBook)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)
local PassiveUtil = require(SSS.Modules.Utils.PassiveUtil)

local floor, random = math.floor, math.random
local fromRGB = Color3.fromRGB
local wait = task.wait
local insert = table.insert
local instanceNew = Instance.new

--[[
	Handle the prompts that triggered
]]
local function promptsHandler(prompt: ProximityPrompt, plr: Player)
	if prompt.Name == "Class" then
		local class = prompt.Parent.Parent.Name

		if plr:GetAttribute("Class") ~= class then
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Equip)
		end

		plr:SetAttribute("Class", class)

	elseif prompt.Name == "Chest" then
		local chest = prompt.Parent.Parent :: Model

		Events.ChestUnlocked:Fire(plr, chest)

		ServerUtil:GiveItem(plr, chest.Name, chest:GetAttribute("Amount") or 1)

	elseif prompt.Name == "Chat" then
		local npc = prompt.Parent.Parent :: Model
		Events.NPCChat:Fire(plr, npc, prompt)

	elseif prompt.Name == "Travel" then
		local destination = prompt.ActionText
		local locator = prompt:GetAttribute("Locator") :: string

		Events.SwitchScene:Fire(plr, 1)

		wait(0.6)
		if workspace.Maps:FindFirstChild(destination)
			and workspace.Maps[destination]:FindFirstChild(locator) then

			plr.Character:PivotTo(workspace.Maps[destination][locator].CFrame)
		end

	elseif prompt.Name == "Material" then
		local hasTool = false
		if prompt.Parent:GetAttribute("Special") then
			local essential = prompt.Parent:GetAttribute("Special")

			if plr.Character:GetAttribute(essential) then hasTool = true end
		else
			hasTool = true
		end

		if not hasTool then return end
		if plr:GetAttribute("MaterialCD") then return end

		plr:SetAttribute("MaterialCD", true)
		Spawn(function()
			wait(1)
			plr:SetAttribute("MaterialCD", nil)
		end)

		prompt.Enabled = false

		local material = prompt.Parent.Parent
		local finalMaterial = material.Name
		if prompt.Parent:GetAttribute("Rare") then
			local rareChance = LootPlan.new()
			local rareMaterial = prompt.Parent:GetAttribute("Rare")
			rareChance:Add(material.Name, 80)
			rareChance:Add(rareMaterial, 20)

			finalMaterial = rareChance:Roll()
			rareChance:Destroy()
		end

		material.Parent = TestS

		ServerUtil:GiveItem(plr, finalMaterial, #material.Items:GetChildren())

		wait(60)
		material.Parent = workspace.MapComponents.Materials
		prompt.Enabled = true

	elseif prompt.Name == "PublicJoin" or prompt.Name == "PartyJoin" then
		local locator = prompt.Parent.Parent

		Events.RejoinCombat:Fire(plr)

		local hinted = false
		local monsters = {}
		for _, monster: Instance in locator:GetDescendants() do
			if monster:HasTag("Monster") then
				if not monster:GetAttribute("SubMonster") then
					insert(monsters, 1, monster)
				else
					insert(monsters, monster)
				end

				if not monster:GetAttribute("OriMaxHealth") then
					monster:SetAttribute("OriMaxHealth", monster:GetAttribute("MaxHealth"))
				end

				local hp = monster:GetAttribute("OriMaxHealth")
				HarukaLib:Add(monster, "MaxHealth", hp)
				HarukaLib:Add(monster, "Health", hp)

				if monster.Holder.Value then
					monster.Holder.Value:SetAttribute(plr.Name, true)
				end

				if hinted then continue end
				hinted = true

				local combatPlrs = {}
				for _, target in monster.TargetingList:GetChildren() do
					local tempPlr = Players:GetPlayerFromCharacter(target.Value)

					if tempPlr then insert(combatPlrs, tempPlr) end
				end

				for _, player in combatPlrs do
					Events.CreateHint:Fire(player, plr.DisplayName.." has joined the combat!", "Hint")
				end
			end
		end
		for _, monster in ipairs(monsters) do
			ServerUtil:AddTargetForMonster(plr, monster)
		end
	end
end
PPS.PromptTriggered:Connect(promptsHandler)

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
			if subMonster:HasTag("Monster") and subMonster:GetAttribute("SubMonster") then
				ServerUtil:AddTargetForMonster(plr, subMonster)

				if not subMonster:GetAttribute("InCombat") then
					ServerUtil:MonsterActivateCombat(subMonster, mode, plr)
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
Events.CombatStart:Connect(combatStartSetup)
Signals.CombatEnd:Connect(combatEndSetup)

--[[
	Player hit the orb and deal dmg to mobs
]]
local function mobTakeDMG(plr: Player, orb: Model)
	local char = plr.Character :: Model
	local HRP = char.PrimaryPart

	--- pre checks
	if not orb:FindFirstChild("Owner") then return end
	if orb.Owner.Value ~= char then return end
	if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
	if not char.CharStats.TargetMonster.Value then return end
	if not HRP then return end
	if not orb.Parent then return end
	if not workspace.MapComponents.OrbFolders:FindFirstChild(plr.Name) then return end

	local monster = char.CharStats.TargetMonster.Value :: Model
	local minDMG, maxDMG = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
	local baseDamage = if minDMG >= maxDMG then maxDMG else random(minDMG, maxDMG)

	orb.Owner:Destroy()

	--- final check
	if not monster.PrimaryPart then return end
	if monster:GetAttribute("CantAttack") then baseDamage = 0 end

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

    --- some hit cd detections
    HarukaLib:Add(char, "HitCD", 5)
    if char:GetAttribute("HitCD") > 5 then char:SetAttribute("HitCD", 5) end

    if not char:FindFirstChild("RepairShield") then
        RepS.Resources.Unloads.RepairShield:Clone().Parent = char
    end
    if not char:FindFirstChild("HealHP") then
        RepS.Resources.Unloads.HealHP:Clone().Parent = char
    end
    char:SetAttribute("Repairing", false)
    char:SetAttribute("Healing", false)

    --- some extra damage
    if dmgPart:GetAttribute("Burn") then SkillUtil:Burn(plr, monster, 6, true) end
    if dmgPart:GetAttribute("Poison") then SkillUtil:Poison(plr, monster, 6, true) end

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

		--- make character full state
		local char = plr.Character :: Model

		char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
		char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
		char.Humanoid.Health = char.Humanoid.MaxHealth

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
		local level = plr:GetAttribute("Levels") - 1
		local cost = (level * LEVEL_POINT - plr:GetAttribute("LvPoints")) * 20

		if plr:GetAttribute("Gold") < cost then
			Events.CreateHint:Fire(plr, "You don't have enough Gold to reset!", "Error")
			return
		end

		HarukaLib:Add(plr, "Gold", -cost)
		plr:SetAttribute("DmgPoints", 0)
		plr:SetAttribute("MagicPoints", 0)
		plr:SetAttribute("ManaPoints", 0)
		plr:SetAttribute("HealthPoints", 0)
		plr:SetAttribute("ShieldPoints", 0)
		plr:SetAttribute("LvPoints", level * LEVEL_POINT)
		return
	end

	if plr:GetAttribute("LvPoints") > 0 then
		for _ = 1, times do
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
	if plr.Inventory:FindFirstChild(item)
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
	Handle the request to make a party
]]
local function makeParty(plr: Player, method: string, target: Player | string)
	local parties = workspace.MapComponents.Parties

	local function _disbandParty()
		for _, player in parties[plr.Name]:GetChildren() do
			if player.Value then player.Value:SetAttribute("InParty", false) end

			Events.CreateHint:Fire(player.Value, "The party has been disbanded by party owner!", "Hint")
		end

		parties[plr.Name]:Destroy()
	end
	if method == "Invite" then
		if not target then return end

		if target:GetAttribute("InviteTicket") then
			Events.CreateHint:Fire(plr, "Player is busying handling with the requests from other players!", "Error")
            return
		end

		Events.PartyInvite:Fire(target, plr)

		target:SetAttribute("InviteTicket", true)
		Spawn(function()
			wait(12)
			target:SetAttribute("InviteTicket", nil)
		end)

	elseif method == "Kick" then
		if not target then return end
		if not parties:FindFirstChild(plr.Name) then return end
		if not parties[plr.Name]:FindFirstChild(target.Name) then return end

		local party = parties[plr.Name]

		party[target.Name]:Destroy()
		target:SetAttribute("InParty", false)

		if target.Name == plr.Name then
			_disbandParty()
			return
		end

		for _, player in party:GetChildren() do
			Events.CreateHint:Fire(player.Value, target.Name.." has left the party...", "Hint")
		end

		if #party:GetChildren() <= 1 then
			party:Destroy()

			plr:SetAttribute("InParty", false)
			Events.CreateHint:Fire(target, "The party has been disbanded due to the lack of people...", "Hint")
		end

		Events.CreateHint:Fire(target, "You have been kicked from the party...", "Hint")

	elseif method == "Accept" then
		if not parties:FindFirstChild(target) and Players:FindFirstChild(target) then
			local owner = instanceNew("Folder")
			owner.Name = target
			owner.Parent = parties

			local leader = instanceNew("ObjectValue")
			leader.Name = target
			leader.Value = Players[target]
			leader.Parent = owner

			Players[target]:SetAttribute("InParty", true)

			Events.CreateHint:Fire(Players[target], "Party created!", "Hint")
		end

		if parties:FindFirstChild(target) then
			local member = instanceNew("ObjectValue")
			member.Name = plr.Name
			member.Value = plr
			member.Parent = parties[target]

			plr:SetAttribute("InParty", true)
		end

		for _, player in parties[target]:GetChildren() do
			Events.CreateHint:Fire(player.Value, target.." has joined the party...", "Hint")
		end

	elseif method == "Leave" then
		local check = parties:FindFirstChild(plr.Name, true)
		if not check then return end

		if check:IsA("Folder") then
			_disbandParty()

		elseif check:IsA("ObjectValue") then
			local folder = check.Parent

			check:Destroy()
			plr:SetAttribute("InParty", false)

			for _, player in folder:GetChildren() do
				Events.CreateHint:Fire(player.Value, plr.Name.." has left the party...", "Hint")
			end

			if #folder:GetChildren() <= 1 then
				local player = folder:FindFirstChildOfClass("ObjectValue")

				player.Value:SetAttribute("InParty", false)
				Events.CreateHint:Fire(player.Value, "The party has been disbanded due to the lack of people...", "Hint")

				folder:Destroy()
				return
			end
		end
	end
end
Events.PartyInvite:Connect(makeParty)

--[[
	Finished chatting with NPCs, and award quest rewards if have
]]
local function npcChatEnded(plr: Player, npc: Model, series: string)
	-- checks
	if not npc then return end
	if not StoryBook[series] then return end
	if not plr.Quests:FindFirstChild(series) then return end

	if series ~= "Town" then
		local currentId = plr.Quests[series].Value :: number
		if StoryBook[series][currentId].NPC ~= npc.Name then return end

		if DialogueBook[npc.Name].Extra[series..currentId] then
			Signals[DialogueBook[npc.Name].Extra[series..currentId]]:Fire(plr)
			return
		end

		ServerUtil:GiveQuestRewards(series, currentId, plr)

		plr.Quests[series]:Destroy()

		local quest = instanceNew("IntConstrainedValue")
		quest.Name = series
		quest.MinValue = 1
		quest.MaxValue = #StoryBook[series]
		quest.Value = currentId + 1
		quest.Parent = plr.Quests

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

	elseif series == "Town" then
		local currentId: number = nil

		for _, quest in plr.Quests:GetChildren() do
			if quest.Name ~= "Town" then continue end
			if StoryBook[series][quest.Value].NPC == npc.Name
				and not plr.Character.CharStats.Quests:FindFirstChild(series..quest.Value) then

				currentId = quest.Value
			end
		end
		if currentId == nil then return end

		ServerUtil:GiveQuestRewards(series, currentId, plr)

		for _, quest in plr.Quests:GetChildren() do
			if quest.Name == "Town" and quest.Value == currentId then quest:Destroy() end
		end

		Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

		if DialogueBook[npc.Name].Extra[series..currentId] then
			Signals[DialogueBook[npc.Name].Extra[series..currentId]]:Fire(plr)
		end
	end
end
Events.NPCChatEnded:Connect(npcChatEnded)

--[[
	Manually give the quest reward
]]
local function _newQuest(series: string, questId: number, plr: Player)
	local newQuest = instanceNew("IntConstrainedValue")
	newQuest.Name = series
	newQuest.MinValue = 1
	newQuest.MaxValue = #StoryBook[series]
	newQuest.Value = questId + 1
	newQuest.Parent = plr.Quests
end
local function questCompleted(series: string, questId: number, plr: Player, needNewQuest: boolean)
	Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.QuestComplete)

	ServerUtil:GiveQuestRewards(series, questId, plr)

	for _, quest: IntConstrainedValue in plr.Quests:GetChildren() do
		if quest.Name == series and quest.Value == questId then
			quest:Destroy()

			if series == "Main" then _newQuest(series, questId, plr) end
		end
	end
	if needNewQuest then _newQuest(series, questId, plr) end
end
Signals.QuestComplete:Connect(questCompleted)

--[[
	Manually give the quest
]]
local function newQuest(plr: Player, npc: Model, series: string, questId: number)
	if StoryBook[series][questId].NPC ~= npc.Name then return end

	local quest = instanceNew("IntConstrainedValue")
	quest.Name = series
	quest.MinValue = 1
	quest.MaxValue = #StoryBook[series]
	quest.Value = questId
	quest.Parent = plr.Quests
end
Events.NewQuest:Connect(newQuest)

--[[
	Handle the request to disable invite access for player
]]
local function toggleInviteAccess(plr: Player)
	plr:SetAttribute("InviteAccess", not plr:GetAttribute("InviteAccess"))
end
Events.ChangeInviteAccess:Connect(toggleInviteAccess)

--[[
	Switch mob target by ctrl or click
]]
local function switchMobTarget(plr: Player, monster: Model)
	local char = plr.Character :: Model

	if monster:HasTag("Monster") and monster:GetAttribute("Health") > 0 then
		char.CharStats.TargetMonster.Value = monster
	end
end
Events.ChangeMobTarget:Connect(switchMobTarget)

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

--[[
	Fix the reset button issue
]]
local function forceReset(plr: Player)
	plr.Character.Humanoid.Health = 0
end
Events.ForceReset:Connect(forceReset)
