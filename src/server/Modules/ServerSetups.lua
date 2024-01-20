--!nocheck

local BS = game:GetService("BadgeService")
local GS = game:GetService("GroupService")
local HttpService = game:GetService("HttpService")
local MS = game:GetService("MessagingService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local PS = game:GetService("PhysicsService")
local PPS = game:GetService("ProximityPromptService")

local HarukaFrameworkServer = require(SSS.Modules.HarukaFrameworkServer)

local Cmdr = HarukaFrameworkServer.Cmdr
local Events = HarukaFrameworkServer.Events
local FastSpawn = HarukaFrameworkServer.FastSpawn
local ServerUtil = HarukaFrameworkServer.ServerUtil

local package = RepS.Package
local resources = RepS.Resources

local ServerSetups = {}
ServerSetups.__index = ServerSetups

local instanceNew = Instance.new
local wait = task.wait
local sub, upper = string.sub, string.upper

--[[
    Setups when server starts
]]
function ServerSetups:MainSetup()
	--- clear extra events
	for _, mapPart in workspace:GetDescendants() do
		if mapPart:IsA("BasePart") then mapPart.CanTouch = false end
	end
	for _, link in RepS:GetDescendants() do
		if link:IsA("PackageLink") then link:Destroy() end
	end

	--- npc setups
	for _, npc in workspace.MapComponents.NPCs:GetChildren() do
		npc.Humanoid.Animator:LoadAnimation(package.Animations.NPCIdle):Play()
	end

	--- sound setups
	local musicSG = instanceNew("SoundGroup")
	musicSG.Name = "Musics"
	musicSG.Parent = SoundService
	local sfxSG = instanceNew("SoundGroup")
	sfxSG.Name = "SFXs"
	sfxSG.Parent = SoundService
	local sounds = instanceNew("Folder")
	sounds.Name = "Sounds"
	sounds.Parent = workspace
	for _, sound in package.Sounds:GetChildren() do
		if sound.Name == "SFXs" then
			for _, sfx in sound:GetChildren() do sfx.SoundGroup = sfxSG end
		else
			sound.SoundGroup = musicSG
		end

		sound:Clone().Parent = sounds
	end
	for _, child in package.MonsterAttacks:GetDescendants() do
		if child:IsA("Sound") then child.SoundGroup = sfxSG end
	end

	--- zone setups
	for _, zone in SS.Zones:GetChildren() do
		zone.Transparency = 1
		zone.Parent = workspace.MapComponents.Zones
	end

	--- monster setups
	for _, child in resources.MonsterAttacks:GetChildren() do
		if package.MonsterModels:FindFirstChild(child.Name) then
			child.Parent = package.MonsterModels[child.Name]
			child.Name = "Attack"
			child.Disabled = true
		end
	end
	for _, child in package.MonsterModels:GetChildren() do
		local targetingList = instanceNew("Folder")
		targetingList.Name = "TargetingList"
		targetingList.Parent = child

		local waitingList = instanceNew("Folder")
		waitingList.Name = "WaitingList"
		waitingList.Parent = child

		local effects = instanceNew("Folder")
		effects.Name = "EffectsList"
		effects.Parent = child

		local holder = instanceNew("ObjectValue")
		holder.Name = "Holder"
		holder.Parent = child
	end
	for _, child in package.MonsterAttacks:GetDescendants() do
		if resources.MonsterBlastAttacks:FindFirstChild(child.Name) then
			resources.MonsterBlastAttacks[child.Name].Parent = child
		end
	end
	for _, locator in workspace.Monsters:GetDescendants() do
		if locator:GetAttribute("MonsterLocation") then ServerUtil:SetupMonster(locator) end
	end

	--- player attacks setups
	for _, child in package.PlayerAttacks:GetChildren() do
		if child:GetAttribute("IsOrb") then
			resources.Unloads.OrbAnim:Clone().Parent = child
		end
		if child:IsA("BillboardGui") and resources.Unloads:FindFirstChild(child.Name) then
			resources.Unloads[child.Name].Parent = child
		end
	end
	resources.Unloads.BorderColorTween.Parent = package.Unloads.CombatBorder.Border

	--- player extra info setup
	local joinData
	Players.PlayerAdded:Connect(function(plr)
		BS:AwardBadge(plr.UserId, 2129794618)

		local groups = GS:GetGroupsAsync(plr.UserId)
		local rank = 0
		for _, group in groups do
			if group.Id == 16912246 then rank = group.Rank end
		end
		plr:SetAttribute("Rank", rank)

		if rank == 2 then plr:SetAttribute("Role", "Artist") end
		if rank == 3 then plr:SetAttribute("Role", "Tester") end
		if rank == 4 then plr:SetAttribute("Role", "Head Tester") end

		--- some other CA series developers should be included as well
		if plr.UserId == 304008764 then plr:SetAttribute("Role", "CStory Founder") end
		if plr.UserId == 68027875 then plr:SetAttribute("Role", "CW Founder") end
		if plr.UserId == 2040399306 then plr:SetAttribute("Role", "CSV Founder") end
		if plr.UserId == 1097119343 then plr:SetAttribute("Role", "CV Founder") end
		if plr.UserId == 3563941913 then plr:SetAttribute("Role", "CO Founder") end

		joinData = plr:GetJoinData().TeleportData
	end)

	--- join friend in titlescreen return info
	MS:SubscribeAsync("ReturnFriendLocation", function(message)
		for _, player in Players:GetPlayers() do
			if player.UserId == message.Data then
				MS:PublishAsync("JoinFriendCheck", game.JobId)
			end
		end
	end)

	--- private server setup
	FastSpawn(function()
		local privateId, code = game.PrivateServerId, nil

		if privateId ~= "" then
			repeat wait() until joinData

			code = joinData[2]
			local accessCode = sub(privateId, 1, 8)
			accessCode = upper(accessCode)

			MS:SubscribeAsync("ReturnAllPrivateServers", function(message)
				if message.Data == accessCode then
					MS:PublishAsync("JoinPrivateCheck", { accessCode, code })
				end
			end)

			package.PrivateServerId.Value = accessCode

			print("Private Server Id: "..accessCode)
		end
	end)

	--- server location info
	FastSpawn(function()
		if RS:IsStudio() then return end

		local serverInfo = HttpService:GetAsync("http://ip-api.com/json/", true)

		if serverInfo then
			local realInfo = HttpService:JSONDecode(serverInfo)
			local serverLocation = realInfo.countrycode

			if serverLocation then
				RepS.Package.ServerLocation.Value = serverLocation

				print("Server Location: "..serverLocation)
			end
		else
			warn("Failed to fetch IP data")
		end
	end)
end

--[[
	Create the collision groups, which are players, npcs and combat border
]]
function ServerSetups:CollisionRegister()
	PS:RegisterCollisionGroup("Player")
	PS:RegisterCollisionGroup("NPC")
	PS:RegisterCollisionGroup("Barrier")

	PS:CollisionGroupSetCollidable("Player", "Player", false)
	PS:CollisionGroupSetCollidable("Player", "NPC", false)
	PS:CollisionGroupSetCollidable("Player", "Barrier", true)
	PS:CollisionGroupSetCollidable("NPC", "NPC", false)
	PS:CollisionGroupSetCollidable("NPC", "Barrier", false)

	ServerUtil:SetCollisionGroup(RepS.Package.MonsterModels, "NPC")
	ServerUtil:SetCollisionGroup(workspace.Monsters, "NPC")
	ServerUtil:SetCollisionGroup(workspace.MapComponents.NPCs, "NPC")
	ServerUtil:SetCollisionGroup(RepS.Package.Unloads["CombatBorder"], "Barrier")
end

--[[
	Register Cmdr module
]]
function ServerSetups:CmdrRegister()
	Cmdr:RegisterDefaultCommands({"Help", "DefaultAdmin"})
	Cmdr:RegisterCommandsIn(SSS.Modules.Commands)
	Cmdr:RegisterHooksIn(SSS.Modules.Hooks)
end

--[[
	Handle all the prompts requests
]]
function ServerSetups:PromptsHandler(prompt: ProximityPrompt, plr: Player)
	if prompt.Name == "Class" then
		local class = prompt.Parent.Parent.Name

		if not plr:GetAttribute("Class") == class then
			Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Equip)
		end

		plr:SetAttribute("Class", class)

	elseif prompt.Name == "Chest" then
		local chest = prompt.Parent.Parent

		if not plr.Inventory:FindFirstChild(chest.Name) then
			Events.ChestUnlocked:Fire(plr, chest)
		end

		ServerUtil:GiveItem(plr, chest.Name, 1)

	elseif prompt.Name == "PublicJoin" then
		local locator = prompt.Parent.Parent

		ServerUtil:AddTargetForMonster(plr, locator:FindFirstChildOfClass("Model"))
	end
end

return function ()
    local self = setmetatable({}, ServerSetups)

	self.ATTRIBUTES = {
		CriChance = 1,
		InCombat = false,
		Magic = 20,
		Mana = 100,
		Damage = 15,
		MaxMana = 100,
		MaxShield = 20,
		OrbLifeTime = 15,
		Shield = 20,

		HealthBuff = 0,
		JumpBuff = 0,
		MagicBuff = 0,
		ManaBuff = 0,
		DamageBuff = 0,
		ShieldBuff = 0,
		SpeedBuff = 0,
	}

	--// Connections
	Players.PlayerAdded:Connect(function(plr)
		if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
			plr.CharacterAdded:Connect(function(char)
				ServerUtil:SetCollisionGroup(char, "Player")
			end)
		end
	end)
	PPS.PromptTriggered:Connect(function(prompt: ProximityPrompt, plr: Player)
		self:PromptsHandler(prompt, plr)
	end)

	--// Setups
	self:CollisionRegister()
	self:CmdrRegister()
    self:MainSetup()

	require(script.Parent.PlayerSetups)()
end
