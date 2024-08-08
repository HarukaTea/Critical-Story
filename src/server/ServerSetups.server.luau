--!nocheck

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
local Promise = require(RepS.Modules.Packages.Promise)

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
	Cmdr:RegisterCommandsIn(SSS.Modules.Commands)
	Cmdr:RegisterHooksIn(SSS.Modules.Hooks)
end
Spawn(cmdrRegister)

local function mainSetup()
	--- game setups
	Spawn(function()
		local combatFolder = instanceNew("Folder")
		combatFolder.Name = "CombatHolders"
		combatFolder.Parent = workspace.MapComponents

		local orbFolder = instanceNew("Folder")
		orbFolder.Name = "OrbHolders"
		orbFolder.Parent = workspace.MapComponents
	end)

	--- clear trees
	for _, obj: Instance in workspace.Maps:GetDescendants() do
		if obj:IsA("Model") and string.find(obj.Name, "Tree") then
			obj.Parent = RepS.Debris.Trees
		end
	end

	--- clear links
	Spawn(function()
		for _, child: Instance in RepS:GetDescendants() do
			if child:IsA("PackageLink") then child:Destroy() end
 		end
	end)

	--- clear touches
	Spawn(function()
		for _, child: Instance in workspace:GetDescendants() do
			if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
				if child:HasTag("Bounce") then continue end

				child.CanTouch = false
			end
		end
	end)

	--- npc setups
	Spawn(function()
		for _, npc: Model in workspace.MapComponents.NPCs:GetChildren() do
			local ref = npc:GetAttribute("Animation") or "DefaultIdle"
			local humanoid = npc.Humanoid :: Humanoid

			humanoid.Animator:LoadAnimation(RepS.Package.Animations.NPCAnims[ref]):Play()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)

			ServerUtil:SetCollisionGroup(npc, "NPC")
		end
	end)

	--- sound setups
	Spawn(function()
		RepS.Package.Unloads.Musics.Parent = SoundService
		RepS.Package.Unloads.SFXs.Parent = SoundService
		for _, sound: Sound in RepS.Package.Sounds:GetDescendants() do
			if sound.Parent.Name == "SFXs" then sound.SoundGroup = SoundService.SFXs continue end
			if sound.Parent.Name == "StoryMusics" then continue end
			if sound:IsA("Sound") then sound.SoundGroup = SoundService.Musics end
		end
		RepS.Package.Sounds.Parent = workspace
		for _, child: Instance in RepS.Package.MonsterAttacks:GetDescendants() do
			if child:IsA("Sound") then child.SoundGroup = SoundService.SFXs end
		end
	end)

	--- zone setups
	Spawn(function()
		SS.Package.Zones.Parent = workspace.MapComponents

		for _, zone: BasePart in workspace.MapComponents.Zones:GetDescendants() do
			if zone:IsA("BasePart") then
				zone.Transparency = 1
				zone.CanCollide = false
				zone.CanQuery = false
				zone.CanTouch = true
			end
		end
	end)

	--- monster setups
	Spawn(function()
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

			local animationPlayer = instanceNew("AnimationController")
			animationPlayer.Parent = child

			local animator = instanceNew("Animator")
			animator.Parent = animationPlayer

			SS.Resources.Unloads.MonsterData:Clone().Parent = child
		end
		for _, child: Model in RepS.Package.MonsterAttacks:GetDescendants() do
			local ref = child:GetAttribute("LinkedScript") or child.Name

			if SS.Resources.MonsterBlastAttacks:FindFirstChild(ref) then
				SS.Resources.MonsterBlastAttacks[ref]:Clone().Parent = child
			end
		end

		for _, locator: Instance in workspace.Monsters:GetDescendants() do
			if locator:HasTag("MonsterLocation") then locator.Transparency = 1 end
		end
	end)

	--- player attacks setups
	Spawn(function()
		for _, orb: Model in RepS.Package.PlayerAttacks:GetChildren() do
			SS.Resources.Unloads.OrbAnim:Clone().Parent = orb

			local ownerSymbol = instanceNew("ObjectValue")
			ownerSymbol.Name = "Owner"
			ownerSymbol.Parent = orb

			for _, part: BasePart in orb:GetChildren() do
				if not part:IsA("BasePart") then continue end

				part.CanTouch = false
				part.CanQuery = false
				part.CanCollide = false
				part.CastShadow = false
			end

			orb.Part.CanTouch = true
		end
		SS.Resources.Unloads.BorderColorTween:Clone().Parent = RepS.Package.Unloads.CombatBorder.Border
	end)

	--- player extra info setup
	local joinData: table?
	Spawn(function()
		local function _playerAdded(plr: Player)
			joinData = plr:GetJoinData().TeleportData
		end
		Players.PlayerAdded:Connect(_playerAdded)
	end)

	--- messages
	Spawn(function()
		MS:SubscribeAsync("JoinFriendRequest", function(message: table)
			for _, plr: Player in Players:GetPlayers() do
				if plr.UserId == message.Data then
					MS:PublishAsync("JoinFriendReturn", { plr.UserId, game.JobId, workspace:GetAttribute("WorldType") })
					break
				end
			end
		end)

		MS:SubscribeAsync("JoinUserRequest", function(message: table)
			for _, plr: Player in Players:GetPlayers() do
				if plr.UserId == message.Data then
					MS:PublishAsync("JoinUserReturn", { plr.UserId, game.JobId, game.PlaceId })
					break
				end
			end
		end)
	end)

	--- private server setup
	Spawn(function()
		local privateId, code = game.PrivateServerId, nil

		if privateId ~= "" then
			repeat wait() until joinData

			code = joinData[2]
			local accessCode = sub(privateId, 1, 8)
			accessCode = upper(accessCode)

			MS:SubscribeAsync("ReturnAllPrivateServers", function(message: table)
				if message.Data == accessCode then
					MS:PublishAsync("JoinPrivateCheck", { accessCode, code, workspace:GetAttribute("WorldType") })
				end
			end)

			RepS.Package.PrivateServerId.Value = accessCode

			print("Private Server Id: "..accessCode)
		end
	end)

	--- server location info
	Spawn(function()
		if RS:IsStudio() then return end

		Promise.new(function()
			local serverInfo = HttpService:GetAsync("https://ipconfig.io/json", false)

			if serverInfo then
				local realInfo = HttpService:JSONDecode(serverInfo) :: table
				local serverLocation = realInfo["country_iso"] :: string

				if serverLocation then
					RepS.Package.ServerLocation.Value = serverLocation

					print("Server Location: "..serverLocation)
				end
			end

		end):catch(function()
			warn("Failed to fetch Server Location.")

			RepS.Package.ServerLocation.Value = "Unknown"
		end)
	end)
end
mainSetup()
