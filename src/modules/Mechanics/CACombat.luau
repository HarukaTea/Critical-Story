--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local TestS = game:GetService("TestService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Clock = require(RepS.Modules.Packages.Clock)
local Collection = require(RepS.Modules.Packages.Collection)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local musics = workspace:WaitForChild("Sounds")
local sfxs = musics.SFXs
local mapComponents = workspace:WaitForChild("MapComponents")
local monsterLocations = workspace:WaitForChild("Monsters")

local isInCombat, isPlaying = false, ""
local orbTouchCD, animStep = false, 1
local dmgTouchCD = false
local encounterCD = false

local cfAngles, cfNew = CFrame.Angles, CFrame.new
local wait = task.wait
local format = string.format
local newInstance, csNew = Instance.new, ColorSequence.new
local v3New = Vector3.new
local rad, random = math.rad, math.random
local fromScale = UDim2.fromScale
local tFind = table.find

local function hitVFX(monster: Model, char: Model)
	local plr = Players:GetPlayerFromCharacter(char)

	--- checks
	if not monster then return end
	if not monster.PrimaryPart then return end

	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

	local hitEff = RepS.Package.Effects.HitEffect:Clone() :: Part
	hitEff.CFrame = monster.PrimaryPart.CFrame
	hitEff.Parent = workspace
	Debris:AddItem(hitEff, 5)
	Debris:AddItem(hitEff.Particle, 2)

	Spawn(function()
		wait(0.2)
		hitEff.Particle.Enabled = false
	end)

	if random(1, 2) == 1 then hitEff.Effect.Image.Image = "rbxassetid://2771196128" end

	local class = plr:GetAttribute("Class")
	hitEff.Effect.Image.ImageColor3 = AssetBook.ClassInfo[class].Color
	hitEff.Particle.Color = csNew(AssetBook.ClassInfo[class].Color)
	hitEff.Effect.Image.Rotation = random(1, 360)

	TS:Create(hitEff.Effect, AssetBook.TweenInfos.fourHalf, { Size = fromScale(30, 30) }):Play()
	TS:Create(hitEff.Effect.Image, AssetBook.TweenInfos.fourHalf, { ImageTransparency = 1 }):Play()
end

local function setCharacterTransparency(trans: number, char: Model)
	for _, child in char:GetChildren() do
		if child:IsA("Part") and child.Name ~= "HumanoidRootPart" then child.Transparency = trans end
		if child:IsA("Model") then
			for _, descendant in child:GetChildren() do
				if descendant.Name == "Part" then descendant.Transparency = trans end
			end
		end
		if child:IsA("Accessory") then child.Handle.Transparency = trans end
	end
end

local function setup(char: Model)
	local plr = Players:GetPlayerFromCharacter(char)

	local function _partyCheck() : boolean
		local partyCheck = true

		if not plr:GetAttribute("InParty") then partyCheck = false end

		local check = mapComponents.Parties:FindFirstChild(char.Name, true)
		if not check then partyCheck = false end

		if check then
			if check:IsA("Folder") then
				if not check:FindFirstChild(char.Name) then partyCheck = false end

			elseif check:IsA("ObjectValue") then
				if not check.Parent:FindFirstChild(char.Name) then partyCheck = false end
			end
		end

		return partyCheck
	end

	for _, folder in mapComponents.CombatFolders:GetChildren() do
		if folder:GetAttribute("PublicCombat") then
			if folder:GetAttribute(char.Name) then folder:Destroy() continue end

			folder.Parent = TestS

		elseif folder:GetAttribute("PartyCombat") then
			if not _partyCheck() then folder:Destroy() continue end

			folder.Parent = TestS
		else
			folder:Destroy()
		end
	end
	for _, folder in mapComponents.OrbFolders:GetChildren() do folder:Destroy() end

	Collection("CombatHolder", function(folder: Folder)
		wait()
		local owner = folder:WaitForChild("Owner")
		repeat wait() until owner.Value

		if not owner.Value.TargetingList:FindFirstChild(char.Name) then
			if folder:GetAttribute("PublicCombat") then
				folder.Parent = TestS

			elseif folder:GetAttribute("PartyCombat") then
				if _partyCheck() then folder.Parent = TestS return end

				folder:Destroy()
			else
				folder:Destroy()
			end
		end
	end)
	Collection("OrbHolder", function(folder: Folder)
		wait()
		if folder.Name ~= char.Name then folder:Destroy() end
	end)
	Collection("CombatJoinPrompt", function(prompt: ProximityPrompt)
		wait()
		if prompt.Name == "PublicJoin" then
			if prompt:GetAttribute("Owner") == char.Name then prompt:Destroy() end

		elseif prompt.Name == "PartyJoin" then
			if prompt:GetAttribute("Owner") == char.Name then prompt:Destroy() end

			if not _partyCheck() then prompt:Destroy() end
		end
	end)

	local function _rotateSimulate()
        for _, monster in monsterLocations:GetDescendants() do
            if monster:GetAttribute("IsMonster") and monster.PrimaryPart and not monster:GetAttribute("InCombat") then
                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 256 then
                    local rotating = random(5, 20)
                    local direction = random(-2, 2)

					for _ = 1, rotating do
						monster.PrimaryPart.CFrame *= cfAngles(0, rad(direction * 5), 0)
						wait(0.01)
					end
                end
            end
        end
    end
    local function _detectMonsters()
		if isInCombat then return end
		if encounterCD then return end

        for _, monster in monsterLocations:GetDescendants() do
            if monster:GetAttribute("IsMonster")
				and monster.PrimaryPart
				and monster:GetAttribute("InCombat") == false
				and not monster:GetAttribute("SubMonster") then

                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 20 then
					encounterCD = true

                    Events.CombatStart:Fire(monster, plr:GetAttribute("CombatMode"))

					wait(2)
					encounterCD = false
                end
            end
        end
    end

    return Clock(1.5, _rotateSimulate), Clock(0.15, _detectMonsters)
end

local function returnFunc(plr: Player)
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char.Humanoid

	--// Connections

	local function _startCombat(monster: Model)
		--- checks
		assert(monster, "Can't find monster when starting combat!")
		assert(monster.Parent:GetAttribute("MonsterLocation"), "Are you sure you passed in a monster?")

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
	local function _endCombat()
		--- checks
		if not isInCombat then return end

		if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

		isInCombat = false

		humanoid.AutoRotate = true
		musics[isPlaying]:Stop()

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
	Fusion.Hydrate(char)({
		[Fusion.AttributeChange("InCombat")] = function(state)
			if state then
				_startCombat(char.CharStats.TargetMonster.Value)

			elseif state == false then --- in case nil
				_endCombat()
			end
		end
	})

	local function _magicCasted()
		local class = plr:GetAttribute("Class") :: string
		local monster = char.CharStats.TargetMonster.Value :: Model?

		--- checks
		if not monster then return end

		local spClass = { "Wizard", "Alchemist", "Illusionist" }
		Signals.PlayAnimation:Fire(if tFind(spClass, class) then "MagicCastedAnim2" else "MagicCastedAnim1")

		char.Humanoid.AutoRotate = false
		char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

		wait(0.2)
		char.Humanoid.AutoRotate = true
	end
	Events.MagicCasted:Connect(_magicCasted)

	local function _onTouched(hit: BasePart)
		if not hit or not hit.Parent then return end

		if hit.Parent:GetAttribute("IsOrb") then
			local orb = hit.Parent :: Model
			local HRP = char.PrimaryPart

			--- checks
			if orbTouchCD then return end
			if not orb:FindFirstChild("Owner") then return end
			if orb.Owner.Value ~= char then return end
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

				hitVFX(char.CharStats.TargetMonster.Value, char)
			end

			orb:Destroy()
			animStep = if animStep == 1 then 2 else 1

		elseif hit.Parent:GetAttribute("IsDamage") then
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

			for _ = 1, 5 do
				setCharacterTransparency(0.5, char)
				wait(0.05)

				setCharacterTransparency(0, char)
				wait(0.05)
			end
		end
	end
	humanoid.Touched:Connect(_onTouched)

	--// Setup
	local stopSimulating, stopDetecting = setup(char)

	--// Destroy
	local function _onDead()
		Events.MagicCasted:DisconnectAll()

		stopSimulating()
		stopDetecting()
	end
	humanoid.Died:Once(_onDead)
end

return returnFunc
