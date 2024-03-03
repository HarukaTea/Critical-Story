--!nocheck

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

local package = RepS.Package
local resources = RepS.Resources

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
collisionRegister()

local function cmdrRegister()
	Cmdr:RegisterDefaultCommands({"Help", "DefaultAdmin"})
	Cmdr:RegisterCommandsIn(SSS.Modules.Commands)
	Cmdr:RegisterHooksIn(SSS.Modules.Hooks)
end
cmdrRegister()

local function mainSetup()
	--- clear extra events
	for _, mapPart in workspace:GetDescendants() do
		if mapPart:IsA("BasePart") then
			if mapPart:HasTag("Water") then continue end
			if mapPart:HasTag("Walljump") then continue end

			mapPart.CanTouch = false
		end
	end
	for _, link in RepS:GetDescendants() do
		if link:IsA("PackageLink") then link:Destroy() end
	end

	--- npc setups
	for _, npc in workspace.MapComponents.NPCs:GetChildren() do
		npc.Humanoid.Animator:LoadAnimation(package.Animations.NPCIdle):Play()
	end

	--- sound setups
	RepS.Package.Unloads.Musics.Parent = SoundService
	RepS.Package.Unloads.SFXs.Parent = SoundService
	for _, sound in package.Sounds:GetChildren() do
		if sound.Name == "SFXs" then
			for _, sfx in sound:GetChildren() do sfx.SoundGroup = SoundService.SFXs end
		else
			sound.SoundGroup = SoundService.Musics
		end
	end
	package.Sounds.Parent = workspace
	for _, child in package.MonsterAttacks:GetDescendants() do
		if child:IsA("Sound") then child.SoundGroup = SoundService.SFXs end
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
		if locator:HasTag("MonsterLocation") then
			RepS.Package.Unloads.CombatEnd:Clone().Parent = locator

			ServerUtil:SetupMonster(locator)
			ServerUtil:ConnectMob(locator)
		end
	end

	--- player attacks setups
	for _, child in package.PlayerAttacks:GetChildren() do
		resources.Unloads.OrbAnim:Clone().Parent = child
	end
	resources.Unloads.BorderColorTween.Parent = package.Unloads.CombatBorder.Border

	--- player extra info setup
	local joinData
	Players.PlayerAdded:Connect(function(plr)
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
		if plr.UserId == 91364976 then plr:SetAttribute("Role", "CR Founder") end

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
	Spawn(function()
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
	Spawn(function()
		if RS:IsStudio() then return end

		local serverInfo = HttpService:GetAsync("https://ipapi.co/json", true)

		if serverInfo then
			local realInfo = HttpService:JSONDecode(serverInfo)
			local serverLocation = realInfo.country

			if serverLocation then
				RepS.Package.ServerLocation.Value = serverLocation

				print("Server Location: "..serverLocation)
			else
				warn("Fetched IP data, but is empty")
			end
		else
			warn("Failed to fetch IP data")
		end
	end)
end
mainSetup()
