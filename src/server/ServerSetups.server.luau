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

local Cmdr = require(RepS.Modules.Packages.Cmdr)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Spawn = require(RepS.Modules.Packages.Spawn)

local instanceNew = Instance.new
local wait = task.wait
local sub, upper = string.sub, string.upper

local function collisionRegister()
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
Spawn(collisionRegister)

local function cmdrRegister()
	Cmdr:RegisterDefaultCommands({ "DefaultAdmin", "DefaultUtil", "DefaultDebug", "Help" })
	Cmdr:RegisterCommandsIn(SSS.Modules.Commands)
	Cmdr:RegisterHooksIn(SSS.Modules.Hooks)
end
Spawn(cmdrRegister)

local function mainSetup()
	--- ray cancels
	for _, mapPart: Instance in workspace:GetDescendants() do
		if mapPart:HasTag("Bounce") then continue end
		if mapPart:HasTag("Water") then continue end

		if mapPart:IsA("BasePart") then
			mapPart.CanTouch = false
			mapPart.Locked = true
		end
	end

	--- game setups
	local combatFolder = instanceNew("Folder")
	combatFolder.Name = "CombatHolders"
	combatFolder.Parent = workspace.MapComponents
	local orbFolder = instanceNew("Folder")
	orbFolder.Name = "OrbHolders"
	orbFolder.Parent = workspace.MapComponents

	--- clear extra events
	for _, link: Instance in RepS:GetDescendants() do
		if link:IsA("PackageLink") then link:Destroy() end
	end

	--- npc setups
	for _, npc: Model in workspace.MapComponents.NPCs:GetChildren() do
		npc.Humanoid.Animator:LoadAnimation(RepS.Package.Animations.NPCIdle):Play()

		ServerUtil:SetCollisionGroup(npc, "NPC")
		ServerUtil:CancelRaycast(npc, false, true)
	end

	--- sound setups
	RepS.Package.Unloads.Musics.Parent = SoundService
	RepS.Package.Unloads.SFXs.Parent = SoundService
	for _, sound: Sound in RepS.Package.Sounds:GetChildren() do
		if sound.Name == "SFXs" then
			for _, sfx in sound:GetChildren() do sfx.SoundGroup = SoundService.SFXs end
		else
			if sound:IsA("Sound") then sound.SoundGroup = SoundService.Musics end
		end
	end
	RepS.Package.Sounds.Parent = workspace
	for _, child: Instance in RepS.Package.MonsterAttacks:GetDescendants() do
		if child:IsA("Sound") then child.SoundGroup = SoundService.SFXs end
	end

	--- zone setups
	SS.Package.Zones.Parent = workspace.MapComponents
	for _, zone: BasePart in workspace.MapComponents.Zones:GetDescendants() do
		if zone:IsA("BasePart") then
			zone.Transparency = 1
			zone.CanCollide = false
			zone.CanQuery = false
		end
	end

	--- monster setups
	for _, monster: Model in RepS.Package.MonsterModels:GetChildren() do
		local ref = monster:GetAttribute("LinkedScript") or monster.Name

		if SS.Resources.MonsterAttacks:FindFirstChild(ref) then
			local attackScript = SS.Resources.MonsterAttacks[ref]:Clone() :: Script
			attackScript.Disabled = true
			attackScript.Name = "Attack"
			attackScript.Parent = monster
		end
	end
	for _, child: Model in RepS.Package.MonsterModels:GetChildren() do
		local targetPlayers = instanceNew("Folder")
		targetPlayers.Name = "TargetPlayers"
		targetPlayers.Parent = child

		local waitingList = instanceNew("Folder")
		waitingList.Name = "WaitingList"
		waitingList.Parent = child

		local effects = instanceNew("Folder")
		effects.Name = "EffectsList"
		effects.Parent = child

		local attackHolder = instanceNew("ObjectValue")
		attackHolder.Name = "AttackHolder"
		attackHolder.Parent = child

		SS.Resources.Unloads.MonsterData:Clone().Parent = child
	end
	for _, child: Model in RepS.Package.MonsterAttacks:GetDescendants() do
		if SS.Resources.MonsterBlastAttacks:FindFirstChild(child.Name) then
			SS.Resources.MonsterBlastAttacks[child.Name]:Clone().Parent = child
		end
		if child:GetAttribute("LinkedScript") then
			SS.Resources.MonsterBlastAttacks[child:GetAttribute("LinkedScript")]:Clone().Parent = child
		end
	end
	ServerUtil:CancelRaycast(RepS.Package.MonsterAttacks, true)

	for _, locator: Instance in workspace.Monsters:GetDescendants() do
		if locator:HasTag("MonsterLocation") then ServerUtil:SetupMonster(locator) end
	end

	--- player attacks setups
	for _, orb: Model in RepS.Package.PlayerAttacks:GetChildren() do
		SS.Resources.Unloads.OrbAnim:Clone().Parent = orb

		ServerUtil:CancelRaycast(orb, true)
	end
	SS.Resources.Unloads.BorderColorTween:Clone().Parent = RepS.Package.Unloads.CombatBorder.Border

	--- player extra info setup
	local joinData
	local function _playerAdded(plr: Player)
		BS:AwardBadge(plr.UserId, 2129794618)

		local groups = GS:GetGroupsAsync(plr.UserId)
		local rank = 0
		for _, group in groups do
			if group.Id == 16912246 then rank = group.Rank end --// Milkshake shop
		end
		plr:SetAttribute("Rank", rank)

		if rank >= 2 then plr:SetAttribute("Role", "Tester") end
		if rank >= 3 then plr:SetAttribute("Role", "Grand Tester") end
		if rank >= 4 then plr:SetAttribute("Role", "Trello Contributor") end
		if rank >= 125 then plr:SetAttribute("Role", "CStory Contributor") end
		if rank >= 126 then plr:SetAttribute("Role", "CStory Moderator") end

		--- some other CA series developers should be included as well
		if plr.UserId == 304008764 then plr:SetAttribute("Role", "CStory Founder") end
		if plr.UserId == 68027875 then plr:SetAttribute("Role", "CW Founder") end
		if plr.UserId == 2040399306 then plr:SetAttribute("Role", "CSV Founder") end
		if plr.UserId == 1097119343 then plr:SetAttribute("Role", "CV Founder") end
		if plr.UserId == 3563941913 then plr:SetAttribute("Role", "CO Founder") end
		if plr.UserId == 91364976 then plr:SetAttribute("Role", "CR Founder") end

		joinData = plr:GetJoinData().TeleportData
	end
	Players.PlayerAdded:Connect(_playerAdded)

	--- private server setup
	local function _privateServerSetup()
		local privateId, code = game.PrivateServerId, nil

		if privateId ~= "" then
			repeat wait() until joinData

			code = joinData[2]
			local accessCode = sub(privateId, 1, 8)
			accessCode = upper(accessCode)

			MS:SubscribeAsync("ReturnAllPrivateServers", function(message: table)
				if message.Data == accessCode then MS:PublishAsync("JoinPrivateCheck", { accessCode, code }) end
			end)

			RepS.Package.PrivateServerId.Value = accessCode

			print("Private Server Id: "..accessCode)
		end
	end
	Spawn(_privateServerSetup)

	--- server location info
	local function _serverLocationDetection()
		if RS:IsStudio() then return end

		local success = pcall(function()
			local serverInfo = HttpService:GetAsync("https://ipapi.co/json", true)

			if serverInfo then
				local realInfo = HttpService:JSONDecode(serverInfo)
				local serverLocation = realInfo.country

				if serverLocation then
					RepS.Package.ServerLocation.Value = serverLocation

					print("Server Location: "..serverLocation)
				end
			end
		end)

		if not success then
			warn("Failed to fetch Server Location.")

			RepS.Package.ServerLocation.Value = "Unknown"
		end
	end
	Spawn(_serverLocationDetection)
end
mainSetup()
