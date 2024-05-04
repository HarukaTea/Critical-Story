--!nocheck
--!optimize 2
--!native

local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Promise = require(RepS.Modules.Packages.Promise)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local humanoid = char.Humanoid :: Humanoid

local musics = workspace:WaitForChild("Sounds") :: Folder
local sfxs = musics.SFXs :: Folder
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder
local monsterLocations = workspace:WaitForChild("Monsters") :: Folder

local isInCombat = false
local orbTouchCD, animStep = false, 1
local dmgTouchCD = false
local encounterCD = false

local wait = task.wait
local newInstance = Instance.new
local v3New = Vector3.new
local tFind, remove = table.find, table.remove

--// Pre-functions
local function setup()
	for _, folder: Folder in mapComponents.CombatFolders:GetChildren() do folder:Destroy() end
	for _, folder: Folder in mapComponents.OrbFolders:GetChildren() do folder:Destroy() end
	for _, folder: Folder in mapComponents.CageFolders:GetChildren() do folder:Destroy() end

	--- add all mobs
	local monsters = {} :: { Model }
	for _, monster: Model in monsterLocations:GetDescendants() do
		if monster:HasTag("Monster") and not monster:GetAttribute("SubMonster") then monsters[#monsters + 1] = monster end
	end
	local function _handleMonster(monster: Model)
		wait()
		if tFind(monsters, monster) then
			remove(monsters, tFind(monsters, monster))
		else
			if not monster:GetAttribute("SubMonster") then monsters[#monsters + 1] = monster end
		end
	end
	CS:GetInstanceAddedSignal("Monster"):Connect(_handleMonster)
	CS:GetInstanceRemovedSignal("Monster"):Connect(_handleMonster)

	--- detect mobs when player is near them
    return Clock(0.15, function()
		if isInCombat then return end
		if encounterCD then return end

        for _, monster: Model in monsters do
            if monster and monster.PrimaryPart and char.PrimaryPart
				and monster:GetAttribute("InCombat") == false
				and not monster:GetAttribute("SubMonster") then

                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 22 then
					encounterCD = true

                    Events.CombatStart:Fire(monster)

					wait(2)
					encounterCD = false
                end
            end
        end
	end)
end

--// Connections
local function startCombat(monster: Model)
	if not monster then return end
	if not monster.PrimaryPart then return end

	isInCombat = true

	--- sound actions
	musics.Overworld:Stop()
	Spawn(function()
		wait(0.15)
		sfxs.EnterCombat:Play()
	end)
	Spawn(function()
		wait(0.39)
		sfxs.EnterCombat2:Play()
	end)
	musics.Combat:Play()
end
local function endCombat()
	if not isInCombat then return end
	if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

	isInCombat = false
	humanoid.AutoRotate = true

	ClientUtil:FreezePlayerControls("Unfreeze")
	Signals.CameraPointTo:Fire("Reset")

	--- sound actions
	for _, sound: Sound in workspace.Sounds:GetChildren() do
		if sound:IsA("Sound") and sound.Name ~= "Overworld" then sound:Stop() end
	end
	if humanoid.Health <= 0 then
		sfxs.Sad:Play()
		return
	end
	sfxs.CombatEnded:Play()

	wait(2)
	musics.Overworld:Play()
end
local function onTouched(hit: BasePart)
	if not hit then return end
	if not hit.Parent then return end

	if hit.Parent:HasTag("Orb") then
		local orb = hit.Parent :: Model
		local HRP = char.PrimaryPart

		--- checks
		if orbTouchCD then return end

		local check = true
		Promise.new(function(resolve)
			if orb.Owner.Value ~= char then resolve(false) end
			if (char.PrimaryPart.Position - orb.PrimaryPart.Position).Magnitude > 16 then resolve(false) end
		end):andThen(function(result)
			check = result
		end):catch(function()
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
			bv.MaxForce = v3New(1, 1, 1) * 99999999
			bv.Velocity = HRP.CFrame.LookVector + v3New(0, 1, 0) * floatWeight
			bv.Parent = HRP
			Debris:AddItem(bv, 0.05)

			humanoid.AutoRotate = false

			Signals.PlayAnimation:Fire(orb:GetAttribute("Style").."Anim"..animStep)

			ClientUtil:ClassHitVFX(char.CharStats.TargetMonster.Value, char)
		end

		Events.MobTakeDMG:Fire(hit.Parent)

		orb:Destroy()
		animStep = if animStep == 1 then 2 else 1

	elseif hit.Parent:HasTag("MonsterDMG") then
		local damagePart = hit.Parent :: Model

		--- checks
		if dmgTouchCD then return end

		dmgTouchCD = true
		Spawn(function()
			wait(0.55)
			dmgTouchCD = false
		end)

		if char:GetAttribute("Shield") > 0 then sfxs.ShieldAbsorb:Play() end

		Events.CharTakeDMG:Fire(damagePart)

		ClientUtil:CharOnHit(char)
	end
end

local function _destroyInCombat(monster: Model, obj: Instance)
	local success = pcall(function()
		if not monster.TargetingList:FindFirstChild(char.Name) then obj:Destroy() end
	end)

	if not success then obj:Destroy() end
end
local function combatHolderHandler(folder: Folder)
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	_destroyInCombat(owner.Value, folder)
end
local function orbFolderHandler(folder: Folder)
	--- the purpose is to yield enough time, cuz `wait()` is not long
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	if folder.Name ~= char.Name then folder:Destroy() end
end
local function cageHolderHandler(cage: Model)
	local owner = cage:WaitForChild("Owner")
	repeat wait() until owner.Value

	_destroyInCombat(owner.Value, cage)
end

--// Connection setups
Fusion.Hydrate(char)({
	[Fusion.AttributeChange("InCombat")] = function(state: boolean)
		if state then
			startCombat(char.CharStats.TargetMonster.Value)

		elseif state == false then --- must be false, else nil also trigger this
			endCombat()
		end
	end
})
humanoid.Touched:Connect(onTouched)
CS:GetInstanceAddedSignal("CombatHolder"):Connect(combatHolderHandler)
CS:GetInstanceAddedSignal("OrbHolder"):Connect(orbFolderHandler)
CS:GetInstanceAddedSignal("TurnBaseCage"):Connect(cageHolderHandler)

--// Setup
local stopDetecting = setup()

--// Clear
humanoid.Died:Once(stopDetecting)