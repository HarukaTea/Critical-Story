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
local monsterNodes = {}
local encounterCD = false

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
		char:PivotTo(cfNew(locator.Position) * cfNew(0, 5.99, 0))
	end
	local border = RepS.Package.Unloads.CombatBorder:Clone() :: Model
	border:PivotTo(cfNew(locator.Position))
	border.Parent = char

	--- sound actions
	musics.Overworld:Stop()
	sfxs.EnterCombat:Play()

	musics[locator:GetAttribute("Music")]:Play()
end
local function endCombat()
	if not isInCombat then return end
	if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

	isInCombat = false
	humanoid.AutoRotate = true

	--- sound actions
	for _, sound: Sound in workspace.Sounds:GetChildren() do
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
		Promise.new(function(_, reject)
			if orb.Owner.Value ~= char then reject() end
			if (char.PrimaryPart.Position - orb.PrimaryPart.Position).Magnitude > 16 then reject() end

		end):Catch(function()
			check = false
		end)
		if not check then return end

		orbTouchCD = true
		humanoid.Jump = true
		Spawn(function()
			wait(0.1)
			orbTouchCD = false
			humanoid.AutoRotate = true
		end)

		local SFXId = orb:GetAttribute("SFXId") :: string
		local SFX: Sound = if SFXId then sfxs[SFXId] else sfxs.AttackHit
		SFX:Play()

		if not orb:GetAttribute("DisallowFloat") then
			local weight = orb:GetAttribute("FloatWeight") :: number
			local floatWeight: number = if weight then weight else 35

			local bv = newInstance("BodyVelocity")
			bv.MaxForce = Vector3.one * 99999999
			bv.Velocity = char.PrimaryPart.CFrame.LookVector + v3New(0, 1, 0) * floatWeight
			bv.Parent = char.PrimaryPart
			Debris:AddItem(bv, 0.05)

			humanoid.AutoRotate = false

			Signals.PlayAnimation:Fire(`{orb:GetAttribute("Style")}Anim{animStep}`)

			ClientUtil:ClassHitVFX(char.CharStats.TargetMonster.Value, char)
		end

		Events.MobTakeDMG:Fire(hit.Parent)

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

		Events.CharTakeDMG:Fire(hit.Parent)

		ClientUtil:CharOnHit(char)
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

	--- detect mobs when player is near them
    Add(HarukaLib.Clock(0.15, function()
		if isInCombat then return end
		if not char.PrimaryPart then return end
		if encounterCD then return end

		local nearbyMonsters = monsterTree:RadiusSearch(char.PrimaryPart.Position, 20)
		for _, monster: Model in nearbyMonsters do
			if not monster then continue end
			if not monster.PrimaryPart then continue end
			if monster:GetAttribute("SubMonster") then continue end
			if monster:GetAttribute("ExclusivePlayer") then
				if monster:GetAttribute("ExclusivePlayer") ~= plr.Name then continue end
			end

			encounterCD = true
			Events.CombatStart:Fire(monster.Parent)

			wait(2)
			encounterCD = false
			break
		end
	end))

	--- auto-render mobs
	Add(HarukaLib.Clock(0.5, function()
		if not char.PrimaryPart then return end

		for _, locator: BasePart in monsterLocations:GetDescendants() do
			if locator:HasTag("MonsterLocation") and not locator:GetAttribute("InCombat") then
				if locator:FindFirstChildOfClass("Model") then continue end

				local distance = plr:DistanceFromCharacter(locator.Position)

				if distance < 200 and distance > 0 then
					local monster = ClientUtil:SetupMonster(locator)

					--// despawn
					Spawn(function()
						while monster and monster.PrimaryPart do
							wait()
							local mobDistance = plr:DistanceFromCharacter(monster.PrimaryPart.Position)
							if (mobDistance >= 200 and mobDistance > 0) or locator:GetAttribute("InCombat") then monster:Destroy() end
						end
					end)

					--// rotate
					Spawn(function()
						while monster and monster.PrimaryPart do
							wait(1 + math.random(1, 10) / 10)
							if monster:GetAttribute("InCombat") then continue end
							if monster:GetAttribute("CantRotate") then continue end

							local rotating = math.random(5, 20)
							local direction = math.random(-2, 2)

							pcall(function()
								for _ = 1, rotating do
									monster.PrimaryPart.CFrame *= CFrame.Angles(0, math.rad(direction * 5), 0)
									wait(0.01)
								end
							end)
						end
					end)
				end
			end
		end
	end))
end
setup()

--// Clear
humanoid.Died:Once(function()
	for _, node: any in monsterNodes do node:Destroy() end
	monsterTree = nil
	monsterNodes = nil

	Empty()
end)
