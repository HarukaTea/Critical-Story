--!nocheck
--!optimize 2
--!native

local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local TestS = game:GetService("TestService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local ClientUtil = require(RepS.Modules.Utils.ClientUtil)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local musics = workspace:WaitForChild("Sounds") :: Folder
local sfxs = musics.SFXs :: Folder
local mapComponents = workspace:WaitForChild("MapComponents") :: Folder
local monsterLocations = workspace:WaitForChild("Monsters") :: Folder

local isInCombat, isPlaying = false, ""
local orbTouchCD, animStep = false, 1
local dmgTouchCD = false
local encounterCD = false

local cfAngles, cfNew = CFrame.Angles, CFrame.new
local wait = task.wait
local format = string.format
local newInstance = Instance.new
local v3New = Vector3.new
local rad, random = math.rad, math.random
local tFind, remove = table.find, table.remove


--// Pre-functions
local function _partyCheck() : boolean
	local partyCheck = true

	if not plr:GetAttribute("InParty") then partyCheck = false end

	local check = mapComponents.Parties:FindFirstChild(char.Name, true)
	if check then
		if check:IsA("Folder") then
			if not check:FindFirstChild(char.Name) then partyCheck = false end

		elseif check:IsA("ObjectValue") and check.Parent then
			if not check.Parent:FindFirstChild(char.Name) then partyCheck = false end
		end
	else
		partyCheck = false
	end

	return partyCheck
end
local function setup()
	for _, folder: Folder in mapComponents.CombatFolders:GetChildren() do folder:Destroy() end
	for _, folder: Folder in mapComponents.OrbFolders:GetChildren() do folder:Destroy() end

	--- add all mobs
	local monsters = {}
	for _, monster in monsterLocations:GetDescendants() do
		if monster:HasTag("Monster") then monsters[#monsters + 1] = monster end
	end
	local function _handleMonster(monster: Model)
		wait()
		if tFind(monsters, monster) then
			remove(monsters, tFind(monsters, monster))
		else
			monsters[#monsters + 1] = monster
		end
	end
	CS:GetInstanceAddedSignal("Monster"):Connect(_handleMonster)
	CS:GetInstanceRemovedSignal("Monster"):Connect(_handleMonster)

	--- rotate the monsters to make them more "lively"
	local function _rotateSimulate()
        for _, monster: Model in monsters do
            if monster.PrimaryPart and not monster:GetAttribute("InCombat") then
                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 166 then
                    local rotating = random(5, 20)
                    local direction = random(-2, 2)

					Spawn(function()
						wait(random(0, 6) / 10)
						for _ = 1, rotating do
							if not monster and monster.PrimaryPart then break end

							monster.PrimaryPart.CFrame *= cfAngles(0, rad(direction * 5), 0)
							wait(0.01)
						end
					end)
                end
            end
        end
    end

	--- detect mobs when player is near them
    local function _detectMonsters()
		if isInCombat then return end
		if encounterCD then return end

        for _, monster: Model in monsters do
            if monster.PrimaryPart
				and monster:GetAttribute("InCombat") == false
				and not monster:GetAttribute("SubMonster") then

                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 18 then
					encounterCD = true

                    Events.CombatStart:Fire(monster)

					wait(2)
					encounterCD = false
                end
            end
        end
    end

    return Clock(1.75, _rotateSimulate), Clock(0.15, _detectMonsters)
end

--// Connections
local function startCombat(monster: Model)
	--- checks
	if not monster then return end
	if not monster.Parent then return end

	local locator = monster.Parent :: Part

	if isInCombat then return end
	isInCombat = true
	isPlaying = locator:GetAttribute("MusicId") or "Combat"

	musics.Overworld:Pause()
	Spawn(function()
		wait(0.15)
		sfxs.EnterCombat:Play()
	end)
	Spawn(function()
		wait(0.39)
		sfxs.EnterCombat2:Play()
	end)

	local combatMusic = musics[isPlaying] :: Sound
	local pastVolume = combatMusic.Volume

	combatMusic.Volume = 0
	combatMusic:Play()
	TS:Create(combatMusic, AssetBook.TweenInfos.twiceHalfOne, { Volume = pastVolume }):Play()

	if (char.PrimaryPart.Position - monster.PrimaryPart.Position).Magnitude >= 32 then
		char:PivotTo(cfNew(locator.Position) * cfNew(0, 8, 0))
	end

	local border = RepS.Package.Unloads.CombatBorder:Clone() :: Model
	border:PivotTo(cfNew(locator.Position))
	border.Parent = char
end
local function endCombat()
	--- checks
	if not isInCombat then return end

	if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

	isInCombat = false

	humanoid.AutoRotate = true
	for _, sound in workspace.Sounds:GetChildren() do
		if sound:IsA("Sound") and sound.Name ~= "Overworld" then sound:Stop() end
	end

	if humanoid.Health > 0 then
		sfxs.CombatEnded:Play()
	else
		sfxs.Sad:Play()
		return
	end

	wait(3)
	local overworld = musics.Overworld
	local pastVolume = overworld.Volume

	overworld.Volume = 0
	overworld:Resume()
	TS:Create(overworld, AssetBook.TweenInfos.twiceHalfOne, { Volume = pastVolume }):Play()
end
local function magicCasted()
	local class = plr:GetAttribute("Class") :: string
	local monster = char.CharStats.TargetMonster.Value :: Model

	--- checks
	if not monster then return end

	local spClass = { "Wizard", "Alchemist", "Illusionist" }
	Signals.PlayAnimation:Fire(if tFind(spClass, class) then "MagicCastedAnim2" else "MagicCastedAnim1")

	char.Humanoid.AutoRotate = false
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

	wait(0.2)
	char.Humanoid.AutoRotate = true
end
local function onTouched(hit: BasePart)
	if not hit or not hit.Parent then return end

	if hit.Parent:HasTag("Orb") then
		local orb = hit.Parent :: Model
		local HRP = char.PrimaryPart

		--- checks
		if orbTouchCD then return end
		if not orb:FindFirstChild("Owner") then return end
		if orb.Owner.Value ~= char then return end
		if not char.PrimaryPart then return end
		if not orb.PrimaryPart then return end
		if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
		if not char.CharStats.TargetMonster.Value then return end
		if not HRP then return end

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

			local variant = format("%sAnim%s", orb:GetAttribute("Style"), tostring(animStep))
			Signals.PlayAnimation:Fire(variant)

			ClientUtil:ClassHitVFX(char.CharStats.TargetMonster.Value, char)
		end

		Events.MobTakeDMG:Fire(hit.Parent)

		orb:Destroy()
		animStep = if animStep == 1 then 2 else 1

	elseif hit.Parent:HasTag("MonsterDMG") then
		local damagePart = hit.Parent :: Model

		--- checks
		if dmgTouchCD then return end
		if not damagePart:FindFirstChild("Owner") then return end
		if not char.PrimaryPart then return end

		dmgTouchCD = true
		Spawn(function()
			wait(0.55)
			dmgTouchCD = false
		end)

		if char:GetAttribute("Shield") > 0 then sfxs.ShieldAbsorb:Play() end

		Events.CharTakeDMG:Fire(damagePart)

		for _ = 1, 5 do
			ClientUtil:SetCharTrans(0.5, char)
			wait(0.05)

			ClientUtil:SetCharTrans(0, char)
			wait(0.05)
		end
	end
end
local function combatHolderHandler(folder: Folder)
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	local monster = owner.Value :: Model
	if not monster then folder:Destroy() return end
	if not monster:FindFirstChild("TargetingList") then folder:Destroy() return end

	if not monster.TargetingList:FindFirstChild(char.Name) then
		if folder:GetAttribute("PublicCombat") then
			folder.Parent = TestS

		elseif folder:GetAttribute("PartyCombat") then
			if _partyCheck() then folder.Parent = TestS return end

			folder:Destroy()
		else
			folder:Destroy()
		end
	end
end
local function orbFolderHandler(folder: Folder)
	--- the purpose is to yield enough time, cuz `wait()` is not long
	local owner = folder:WaitForChild("Owner") :: ObjectValue
	repeat wait() until owner.Value

	if folder.Name ~= char.Name then folder:Destroy() end
end

--// Connection setups
Fusion.Hydrate(char)({
	[Fusion.AttributeChange("InCombat")] = function(state)
		if state then
			startCombat(char.CharStats.TargetMonster.Value)

		elseif state == false then --- must be false, else nil also trigger this
			endCombat()
		end
	end
})
Events.MagicCasted:Connect(magicCasted)
humanoid.Touched:Connect(onTouched)
CS:GetInstanceAddedSignal("CombatHolder"):Connect(combatHolderHandler)
CS:GetInstanceAddedSignal("OrbHolder"):Connect(orbFolderHandler)

--// Setup
local stopSimulating, stopDetecting = setup()

--// Clear
local function onDead()
	Events.MagicCasted:DisconnectAll()

	stopSimulating()
	stopDetecting()
end
humanoid.Died:Once(onDead)
