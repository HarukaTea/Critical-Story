--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Clock = HarukaFrameworkClient.Clock
local Collection = HarukaFrameworkClient.Collection
local Events = HarukaFrameworkClient.Events
local Fusion = HarukaFrameworkClient.Fusion
local Signals = HarukaFrameworkClient.Signals

local CACombat = {}
CACombat.__index = CACombat

local cfAngles, cfNew = CFrame.Angles, CFrame.new
local delay, wait = task.delay, task.wait
local format = string.format
local newInstance, csNew = Instance.new, ColorSequence.new
local one, yAxis = Vector3.one, Vector3.yAxis
local rad, random = math.rad, math.random
local fromScale = UDim2.fromScale

--[[
    Actions of starting combat, which can only be called once per battle
]]
function CACombat:StartCombat(monster: Model)
	--- checks
	assert(monster, "Can't find monster when starting combat!")
	assert(monster.Parent:GetAttribute("MonsterLocation"), "Are you sure you passed in a monster?")

	local locator = monster.Parent :: Part
	local char = self.char :: Model

	if self.isInCombat then return end
	self.isInCombat = true
	self.isPlaying = locator:GetAttribute("MusicId") or "Combat"

	self.musics.Overworld:Pause()
	delay(0.15, function()
        self.SFXs.EnterCombat:Play()
    end)
    delay(0.39, function()
        self.SFXs.EnterCombat2:Play()
    end)

	local combatMusic = self.musics[self.isPlaying] :: Sound
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

--[[
    Actions of stopping combat, usually be called after combat ends,
    but sometimes it can be used in story combats
]]
function CACombat:StopCombat()
	--- checks
	if not self.isInCombat then return end

	local char = self.char :: Model
	local humanoid = char.Humanoid :: Humanoid

	if char:FindFirstChild("CombatBorder") then char.CombatBorder:Destroy() end

	self.isInCombat = false

	humanoid.AutoRotate = true
	self.musics[self.isPlaying]:Stop()

	if humanoid.Health > 0 then
		self.SFXs.CombatEnded:Play()
	else
		self.SFXs.Sad:Play()
		return
	end

	wait(3)
	local overworld = self.musics.Overworld
	local pastVolume = overworld.Volume

	overworld.Volume = 0
	overworld:Resume()
	TS:Create(overworld, AssetBook.TweenInfos.twiceHalfOne, { Volume = pastVolume }):Play()
end

--[[
	Hit effect of player's orbs
]]
function CACombat:HitVFX(monster: Model)
	--- checks
	if not monster then return end
	if not monster.PrimaryPart then return end

	self.char.PrimaryPart.CFrame = cfNew(self.char.PrimaryPart.Position, monster.PrimaryPart.Position)

	local hitEff = RepS.Package.Effects.HitEffect:Clone() :: Part
	hitEff.CFrame = monster.PrimaryPart.CFrame
	hitEff.Parent = workspace
	Debris:AddItem(hitEff, 5)
	Debris:AddItem(hitEff.Particle, 2)

	delay(0.2, function()
		hitEff.Particle.Enabled = false
	end)

	if random(1, 2) == 1 then hitEff.Effect.Image.Image = "rbxassetid://2771196128" end

	local class = self.plr:GetAttribute("Class")
	hitEff.Effect.Image.ImageColor3 = AssetBook.ClassInfo[class].Color
	hitEff.Particle.Color = csNew(AssetBook.ClassInfo[class].Color)
	hitEff.Effect.Image.Rotation = random(1, 360)

	TS:Create(hitEff.Effect, AssetBook.TweenInfos.fourHalf, { Size = fromScale(30, 30) }):Play()
	TS:Create(hitEff.Effect.Image, AssetBook.TweenInfos.fourHalf, { ImageTransparency = 1 }):Play()
end

--[[
	Set the overall transparency of character with the given number
]]
function CACombat:SetCharacterTransparency(trans: number)
	for _, child in self.char:GetChildren() do
		if child:IsA("Part") and child.Name ~= "HumanoidRootPart" then child.Transparency = trans end
		if child:IsA("Model") then
			for _, descendant in child:GetChildren() do
				if descendant.Name == "Part" then descendant.Transparency = trans end
			end
		end
		if child:IsA("Accessory") then child.Handle.Transparency = trans end
	end
end

--[[
    Handles the event when Touched is fired, only detect orbs and attacks from monsters
]]
function CACombat:OnTouched(hit: BasePart)
	if hit.Parent:GetAttribute("IsOrb") then
		local orb, char = hit.Parent :: Model, self.char :: Model
		local humanoid, HRP = char.Humanoid :: Humanoid, char.PrimaryPart

		--- checks
		if self.orbTouchCD then return end
        if not orb:FindFirstChild("Owner") then return end
        if orb.Owner.Value ~= char then return end
        if (HRP.Position - orb.PrimaryPart.Position).Magnitude > 16 then return end
        if not char.CharStats.TargetMonster.Value then return end
        if not HRP then return end

		self.orbTouchCD = true
		humanoid.Jump = true
		delay(0.2, function()
            self.orbTouchCD = false
            humanoid.AutoRotate = true
        end)

		local SFXId = orb:GetAttribute("SFXId") :: string
		local SFX: Sound = if SFXId then self.SFXs[SFXId] else self.SFXs.AttackHit
		SFX:Play()

		if not orb:GetAttribute("DisallowFloat") then
			local weight = orb:GetAttribute("FloatWeight") :: number
			local floatWeight: number = if weight then weight else 35

			local bv = newInstance("BodyVelocity")
            bv.MaxForce = one * 99999999
            bv.Velocity = HRP.CFrame.LookVector + yAxis * floatWeight
            bv.Parent = HRP
            Debris:AddItem(bv, 0.05)

			humanoid.AutoRotate = false

			local variant = format("%sAnim%s", orb:GetAttribute("Style"), tostring(self.animStep))
			Signals.PlayAnimation:Fire(variant)

			self:HitVFX(char.CharStats.TargetMonster.Value)
		end

		orb:Destroy()
		self.animStep = if self.animStep == 1 then 2 else 1

	elseif hit.Parent:GetAttribute("IsDamage") then
		local damagePart, char = hit.Parent :: Model, self.char :: Model

		--- checks
		if self.dmgTouchCD then return end
		if not damagePart:FindFirstChild("Owner") then return end
		if not char.PrimaryPart then return end

		self.dmgTouchCD = true
		delay(0.55, function()
            self.dmgTouchCD = false
        end)

		if char:GetAttribute("Shield") > 0 then self.SFXs.ShieldAbsorb:Play() end

		for _ = 1, 5 do
			self:SetCharacterTransparency(0.5)
			wait(0.05)

			self:SetCharacterTransparency(0)
			wait(0.05)
		end
	end
end

--[[
    The setup actions, equals to CACombat.new

    Returns two functions of stopping `Clock` class
]]
function CACombat:Setup()
	local monsterLocations = self.monsterLocations
	local char = self.char

	for _, folder in self.mapComponents.CombatFolders:GetChildren() do
		if folder:GetAttribute("PublicCombat") then
			if folder:GetAttribute(char.Name) then folder:Destroy() continue end

		elseif folder:GetAttribute("PartyCombat") then
			--[[
				TODO: party system
			]]

		else
			folder:Destroy()
		end
	end
	for _, folder in self.mapComponents.OrbFolders:GetChildren() do folder:Destroy() end

	Collection("CombatHolder", function(folder: Folder)
		wait()
		local owner = folder:WaitForChild("Owner")

		if not owner.Value.TargetingList:FindFirstChild(char.Name) then
			if folder:GetAttribute("PublicCombat") then
				folder.Parent = RepS.Unloads

			elseif folder:GetAttribute("PartyCombat") then
				--[[
					TODO: Party system
				]]
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
			if prompt:GetAttribute("Owner") == char.Name then prompt.Enabled = false end

		elseif prompt.Name == "PartyJoin" then
			--[[
				TODO: Party system
			]]
			prompt.Enabled = false
		end
	end)

	local function _rotateSimulate()
        for _, monster in monsterLocations:GetDescendants() do
            if monster:GetAttribute("IsMonster") and monster.PrimaryPart and not monster:GetAttribute("InCombat") then

                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 128 then
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
		if self.isInCombat then return end
		if self.encounterCD then return end

        for _, monster in monsterLocations:GetDescendants() do
            if monster:GetAttribute("IsMonster")
				and monster.PrimaryPart
				and monster:GetAttribute("InCombat") == false
				and not monster:GetAttribute("SubMonster") then

                if (monster.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 20 then
					self.encounterCD = true

                    Events.CombatStart:Fire(monster, self.plr:GetAttribute("CombatMode"))

					wait(2)
					self.encounterCD = false
                end
            end
        end
    end

    return Clock(1.5, _rotateSimulate), Clock(0.15, _detectMonsters)
end

--[[
	Friendship is the power of magic!
]]
function CACombat:MagicCasted()
	local class = self.plr:GetAttribute("Class") :: string
	local char = self.char :: Model
	local monster = char.CharStats.TargetMonster.Value :: Model

	--- checks
	if not monster then return end

	if class == "Wizard" or class == "Illusionist" then
		Signals.PlayAnimation:Fire("MagicCastedAnim2")
	else
		Signals.PlayAnimation:Fire("MagicCastedAnim1")
	end

	char.Humanoid.AutoRotate = false
	char.PrimaryPart.CFrame = cfNew(char.PrimaryPart.Position, monster.PrimaryPart.Position)

	wait(0.2)
	char.Humanoid.AutoRotate = true
end

--[[
    The clear actions, and ready for next require
]]
function CACombat:Destroy()
	Events.MagicCasted:Disconnect()

	self.stopSimulating()
	self.stopDetecting()
end

return function (plr: Player)
	local self = setmetatable({}, CACombat)

	self.plr = plr
	self.char = plr.Character or plr.CharacterAdded:Wait()

	self.musics = workspace:WaitForChild("Sounds")
	self.SFXs = self.musics.SFXs
	self.mapComponents = workspace:WaitForChild("MapComponents")
	self.monsterLocations = workspace:WaitForChild("Monsters")

	self.isInCombat, self.isPlaying = false, ""
	self.orbTouchCD, self.animStep = false, 1
	self.dmgTouchCD = false

	local char = self.char
	local humanoid = char:WaitForChild("Humanoid")

	--// Connections
	Fusion.Hydrate(char)({
		[Fusion.AttributeChange("InCombat")] = function(state)
			if state then
				self:StartCombat(char.CharStats.TargetMonster.Value)

			elseif not state then
				self:StopCombat()
			end
		end
	})
	local function _magicCasted()
		self:MagicCasted()
	end
	Events.MagicCasted:Connect(_magicCasted)

	local function _onTouched(hit: BasePart)
		if not hit or not hit.Parent then return end

		self:OnTouched(hit)
	end
	humanoid.Touched:Connect(_onTouched)

	--// Setup
	self.stopSimulating, self.stopDetecting = self:Setup()

	--// Destroy
	local function _onDead()
		self:Destroy()
	end
	humanoid.Died:Once(_onDead)
end
