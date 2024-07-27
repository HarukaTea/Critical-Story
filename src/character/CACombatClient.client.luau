--!nocheck

local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Events = require(RepS.Modules.Data.Events)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Octree = require(RepS.Modules.Packages.DataLibs.Octree)
local Promise = require(RepS.Modules.Packages.Promise)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()
local monsterTree = Octree.new()
local locationTree = Octree.new()

local char = script.Parent :: Model
local humanoid = char:WaitForChild("Humanoid") :: Humanoid
local plr = Players.LocalPlayer

local musics = workspace:WaitForChild("Sounds", 999) :: Folder
local sfxs = musics.SFXs :: Folder
local mapComponents = workspace:WaitForChild("MapComponents", 999) :: Folder
local monsterLocations = workspace:WaitForChild("Monsters", 999) :: Folder

local isInCombat = false
local orbTouchCD, animStep = false, 1
local dmgTouchCD = false
local locatorNodes = {}
local monsterNodes = {}
local encounterCD = false
local currentMonster = nil

local wait = task.wait
local newInstance = Instance.new
local v3New = Vector3.new
local cfNew = CFrame.new

repeat wait() until Players.LocalPlayer:GetAttribute("PlayerDataLoaded")
repeat wait() until char:GetAttribute("CharDataLoaded")


--// Connections
local function startCombat(monster: Model)
	if not monster then return end
	if not monster.PrimaryPart then return end

	local locator: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent

	if isInCombat then return end
	isInCombat = true

	--- border
	if (char.PrimaryPart.Position - locator.Position).Magnitude >= 32 then
		char:PivotTo(cfNew(locator.Position) * cfNew(math.random(-8, 8), 5.99, math.random(-8, 8)))
	end
	local border = RepS.Package.Unloads.CombatBorder:Clone() :: Model
	border:PivotTo(cfNew(locator.Position))
	border.Parent = char

	--- sound actions
	musics.Overworld:Stop()
	sfxs.EnterCombat:Play()

	musics.CombatMusics[locator:GetAttribute("Music") or "Conquest"]:Play()
end
local function endCombat()
	if not isInCombat then return end
	if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

	isInCombat = false
	currentMonster = nil
	humanoid.AutoRotate = true

	--- sound actions
	for _, sound: Sound in workspace.Sounds:GetDescendants() do
		if sound:IsA("Sound") then sound:Stop() end
	end
	if humanoid.Health <= 0 then return end

	sfxs.CombatEnded:Play()
	wait(2)
	musics.Overworld:Play()
end
local function onTouched(hit: BasePart)
	if not hit then return end
	if not hit.Parent then return end

	if hit.Parent:HasTag("Orb") then
		if orbTouchCD then return end

		local orb = hit.Parent :: Model

		local check = true
		Promise.new(function(resolve, reject)
			if orb.Owner.Value ~= char then reject() end

			local distance1 = plr:DistanceFromCharacter(orb.PrimaryPart.Position)
			local distance2 = plr:DistanceFromCharacter(orb.PrimaryPart.Position + v3New(0, 16, 0))
			local distance3 = plr:DistanceFromCharacter(orb.PrimaryPart.Position - v3New(0, 16, 0))

			if distance1 < 16 or distance2 < 16 or distance3 < 16 then resolve() end
			if distance1 <= 0 or distance2 <= 0 or distance3 <= 0 then reject() end

		end):Catch(function()
			check = false
		end)
		if not check then return end

		orbTouchCD = true
		Spawn(function()
			wait(0.1)
			orbTouchCD = false

			wait(0.1)
			humanoid.AutoRotate = true
		end)

		local SFXId = orb:GetAttribute("SFXId") :: string
		local SFX: Sound = if SFXId then sfxs[SFXId] else sfxs.AttackHit
		SFX:Play()

		if not orb:GetAttribute("DisallowFloat") then
			humanoid.Jump = true
			if char.Torso:FindFirstChild("OrbBV") then
				char.Torso.OrbBV:Destroy()
				char.Torso.Velocity = Vector3.zero
			end

			local weight = orb:GetAttribute("FloatWeight") :: number
			local floatWeight: number = if weight then weight else 30

			local bv = newInstance("BodyVelocity")
			bv.Name = "OrbBV"
			bv.MaxForce = Vector3.one * 99999999
			bv.Velocity = char.PrimaryPart.CFrame.LookVector + v3New(0, 1, 0) * floatWeight
			bv.Parent = char.Torso
			Debris:AddItem(bv, 0.05)

			humanoid.AutoRotate = false
			Signals.PlayAnimation:Fire(`{orb:GetAttribute("Style")}Anim{animStep}`)

			local monster = char.CharStats.TargetMonster.Value :: Model?
			if monster then
				ClientUtil:HitVFX(char.CharStats.TargetMonster.Value)

				char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)
			end
		end

		Events.MonsterTakeDMG.Fire({ Orb = orb })

		orb:Destroy()
		animStep = if animStep == 1 then 2 else 1

	elseif hit.Parent:HasTag("MonsterDMG") then
		if dmgTouchCD then return end

		dmgTouchCD = true
		Spawn(function()
			wait(0.55)
			dmgTouchCD = false
		end)

		if char:GetAttribute("Shield") > 0 then sfxs.ShieldAbsorb:Play() end

		Events.PlayerTakeDMG.Fire({ Projectile = hit.Parent })

		ClientUtil:HitVFX(char)
	end
end

local function _destroyInCombat(monster: Model, obj: Instance)
	local success = pcall(function()
		if not monster.TargetPlayers:FindFirstChild(char.Name) then obj:Destroy() end
	end)

	if not success then obj:Destroy() end
end
local function combatHolderHandler(folder: Folder)
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	_destroyInCombat(owner.Value, folder)
end
local function orbFolderHandler(folder: Folder)
	---// the purpose is to yield enough time, cuz `task.wait()` isn't long enough
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	if folder.Name ~= char.Name then folder:Destroy() end
end

--// Connection setups
Add(HarukaLib:Hydrate(char, {
	["Attr-InCombat"] = function(state: boolean)
		if state then
			startCombat(char.CharStats.TargetMonster.Value)

		elseif state == false then ---// must be false, nil also trigger this
			endCombat()
		end
	end
}))
Add(humanoid.Touched:Connect(onTouched))
Add(CS:GetInstanceAddedSignal("CombatHolder"):Connect(combatHolderHandler))
Add(CS:GetInstanceAddedSignal("OrbHolder"):Connect(orbFolderHandler))

--// Setup
local function setup()
	for _, folder: Folder in mapComponents.CombatHolders:GetChildren() do folder:Destroy() end
	for _, folder: Folder in mapComponents.OrbHolders:GetChildren() do folder:Destroy() end

	--- add all mobs
	local function _addMonster(monster: Model)
		wait()
		if monster:GetAttribute("SubMonster") then return end
		repeat wait() until monster.PrimaryPart --// Low-end devices, uhhhh!

		table.insert(monsterNodes, monsterTree:CreateNode(monster.PrimaryPart.Position, monster))
	end
	local function _removeMonster(monster: Model)
		if monster:GetAttribute("SubMonster") then return end

		for index: number, node: any in monsterNodes do
			if node:GetObject() == monster then
				node:Destroy()
				table.remove(monsterNodes, index)
			end
		end
	end
	Add(CS:GetInstanceAddedSignal("Monster"):Connect(_addMonster))
	Add(CS:GetInstanceRemovedSignal("Monster"):Connect(_removeMonster))
	Add(monsterNodes)

	--- add all locations
	for _, locator: BasePart in monsterLocations:GetDescendants() do
		if locator:HasTag("MonsterLocation") then locationTree:CreateNode(locator.Position, locator) end
	end
	local function _addLocation(locator: BasePart)
		wait()
		repeat wait() until locator --- I fear that low-end device may not work lol

		table.insert(locatorNodes, locationTree:CreateNode(locator.Position, locator))
	end
	local function _removeLocation(locator: BasePart)
		for index: number, node: any in locatorNodes do
			if node:GetObject() == locator then
				node:Destroy()
				table.remove(locatorNodes, index)
			end
		end
	end
	Add(CS:GetInstanceAddedSignal("MonsterLocation")):Connect(_addLocation)
	Add(CS:GetInstanceRemovedSignal("MonsterLocation")):Connect(_removeLocation)
	Add(locatorNodes)

	--- detect mobs when player is near them
	Add(HarukaLib.Clock(0.15, function()
		if isInCombat then return end
		if not char.PrimaryPart then return end
		if encounterCD then return end
		if currentMonster then return end

		local nearbyMonsters = monsterTree:RadiusSearch(char.PrimaryPart.Position, 18)
		for _, monster: Model in nearbyMonsters do
			if not monster then continue end
			if not monster.PrimaryPart then continue end
			if monster:GetAttribute("SubMonster") then continue end
			if monster:GetAttribute("ExclusivePlayer") then
				if monster:GetAttribute("ExclusivePlayer") ~= plr.Name then continue end
			end
			if monster:GetAttribute("InCombat") then continue end

			encounterCD = true
			currentMonster = monster

			Events.CombatStart.Fire({ Locator = monster.Parent })

			wait(2)
			encounterCD = false
			break
		end
	end))

	--- auto-render mobs
	Add(HarukaLib.Clock(0.5, function()
		if not char.PrimaryPart then return end

		local nearbyLocators = locationTree:RadiusSearch(char.PrimaryPart.Position, 200)
		for _, locator: BasePart in nearbyLocators do
			if not locator then continue end
			if locator:GetAttribute("InCombat") then continue end
			if locator:FindFirstChildOfClass("Model") then continue end

			local monster = ClientUtil:SetupMonster(locator)
			Add(monster)

			--// despawn
			Spawn(function()
				while monster and monster.PrimaryPart do
					wait()
					if not monster or not monster.PrimaryPart then break end

					local mobDistance = plr:DistanceFromCharacter(monster.PrimaryPart.Position)
					if mobDistance >= 200 or locator:GetAttribute("InCombat") then monster:Destroy() end
				end
			end)

			--// rotate
			Spawn(function()
				while monster and monster.PrimaryPart do
					wait(1 + math.random(1, 10) / 10)
					if not monster or not monster.PrimaryPart then break end
					if monster:GetAttribute("InCombat") then continue end
					if monster:GetAttribute("CantRotate") then continue end

					local rotating = math.random(5, 20)
					local direction = math.random(-2, 2)

					for _ = 1, rotating do
						if not monster or not monster.PrimaryPart then break end

						monster.PrimaryPart.CFrame *= CFrame.Angles(0, math.rad(direction * 5), 0)
						wait(0.01)
					end
				end
			end)
		end
	end))
end
setup()

--// Clear
humanoid.Died:Once(Empty)
