--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local Formula = require(RepS.Modules.Data.Formulas)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local isBroken = false
local lvUpCD = false

local ATTRIBUTES = require(SSS.Modules.Data.CharTemplate)

local wait = task.wait
local floor = math.floor
local instanceNew = Instance.new
local cfNew = CFrame.new

repeat wait() until plr:GetAttribute("PlayerDataLoaded")


local function _createFolder(name: string, parent: Folder) : Folder
    local folder = instanceNew("Folder")
    folder.Name = name
    folder.Parent = parent

    return folder
end
local function setup()
    char.PrimaryPart = char.Humanoid.RootPart

    local function _createStats()
        local charStats = _createFolder("CharStats", char)

        for i: string, v: any in ATTRIBUTES do
            char:SetAttribute(i, v)
        end
        local targetMonster = instanceNew("ObjectValue")
        targetMonster.Name = "TargetMonster"
        targetMonster.Parent = charStats

        _createFolder("Items", charStats)
        _createFolder("ExtraOrbs", charStats)
        _createFolder("EffectsList", charStats)
        _createFolder("TargetMonsters", charStats)
        _createFolder("Quests", charStats)
    end
    _createStats()

    ServerUtil:SetCollisionGroup(char, "Player")

    --// Spawn to the nearest respawn point
    pcall(function()
        if not RS:IsStudio() then
            local area = plr:GetAttribute("LastSeenLocation") :: string
            if not workspace.Maps:FindFirstChild(area) then return end

            char:PivotTo(cfNew(workspace.Maps[area].SpawnPoints.SpawnPoint.Position))
        end
    end)
end
Spawn(setup)


local function cosmeticSetup()
    local cosmetic = plr:GetAttribute("Cosmetic") :: string?

    if cosmetic and cosmetic ~= "None" then ServerUtil:EquipArmor(char, cosmetic) end
end
Spawn(cosmeticSetup)


local function classAttributesSetup()
    --- warrior
    Add(char.Humanoid.StateChanged:Connect(function(state)
        if state == Enum.HumanoidStateType.Landed
            or state ~= Enum.HumanoidStateType.Jumping
            or state ~= Enum.HumanoidStateType.Freefall
        then
            char:SetAttribute("Combo", 0)
        end
    end))

    -- knight
    Add(HarukaLib.Clock(1, function()
        if char:GetAttribute("Guard") > 0 then HarukaLib:AddAttr(char, "Guard", -1) end
    end))

    -- reaper
    Add(HarukaLib.Clock(1.5, function()
        if char:GetAttribute("LifeStolen") > 0 then HarukaLib:AddAttr(char, "LifeStolen", -1) end
    end))

    --- rogue
    Add(HarukaLib.Clock(0.6, function()
        if char:GetAttribute("RogueCri") > 0 then HarukaLib:AddAttr(char, "RogueCri", -1) end
    end))

    _createFolder("AlchemistCreations", char)
end
Spawn(classAttributesSetup)


local function charAttributesSetup()
    local function manaCheck(mana: number)
        local maxMana = char:GetAttribute("MaxMana") :: number

        if mana > maxMana then char:SetAttribute("Mana", maxMana) end
    end
    local function shieldCheck(shield: number)
        local maxShield = char:GetAttribute("MaxShield") :: number

        if shield > 0 and isBroken then isBroken = false end
        if shield >= maxShield then char:SetAttribute("Shield", maxShield) end

        if shield <= 0 and not isBroken and maxShield > 0 then
            isBroken = true

            Events.PlaySound.Fire(plr, { Sound = workspace.Sounds.SFXs.ShieldBroken })
        end
    end

    local shieldAdd, shieldEmpty = HarukaLib.Bin()
    local function shieldRepair()
        shieldEmpty()

        char:SetAttribute("ShieldRepairing", false)

        shieldAdd(task.spawn(function()
            wait(7)
            while wait(0.1599) do
                if char:GetAttribute("Shield") >= char:GetAttribute("MaxShield") or humanoid.Health <= 0 then
                    char:SetAttribute("ShieldRepairing", false)
                    break
                end

                char:SetAttribute("ShieldRepairing", true)

                HarukaLib:AddAttr(char, "Shield", math.ceil(char:GetAttribute("MaxShield") * 0.006))
            end
        end))
    end
    Add(shieldEmpty)

    local healthAdd, healthEmpty = HarukaLib.Bin()
    local function healthRecover()
        healthEmpty()

        char:SetAttribute("HPRecovering", false)

        healthAdd(task.spawn(function()
            wait(15)
            while wait(0.5) do
                if humanoid.Health <= 0 or humanoid.Health >= humanoid.MaxHealth then
                    char:SetAttribute("HPRecovering", false)
                    break
                end

                char:SetAttribute("HPRecovering", true)

                humanoid.Health += math.ceil(humanoid.MaxHealth * 0.01)
            end
        end))
    end
    Add(healthEmpty)

    local function updateMinDMG()
        char:SetAttribute("MinDMG", Formula.PlayerDMGMin(plr:GetAttribute("DMGPoints")) + char:GetAttribute("MinDMGBuff"))
    end
    local function updateMaxDMG()
        char:SetAttribute("MaxDMG", Formula.PlayerDMGMax(plr:GetAttribute("DMGPoints")) + char:GetAttribute("MaxDMGBuff"))
    end
    local function updateMagic()
        char:SetAttribute("Magic", Formula.PlayerMagic(plr:GetAttribute("MagicPoints")) + char:GetAttribute("MagicBuff"))
    end
    local function updateShield()
        char:SetAttribute("MaxShield", Formula.PlayerShield(plr:GetAttribute("ShieldPoints")) + char:GetAttribute("ShieldBuff"))

        shieldRepair()
    end
    local function updateMana()
        char:SetAttribute("MaxMana", Formula.PlayerMana(plr:GetAttribute("ManaPoints")) + char:GetAttribute("ManaBuff"))
    end
    local function updateHP()
        humanoid.MaxHealth = Formula.PlayerHP(plr:GetAttribute("HealthPoints")) + char:GetAttribute("HealthBuff")

        healthRecover()
    end
    local function updateSpeed()
        local baseSpeed = if char:GetAttribute("InCombat") then 30 else 40

        humanoid.WalkSpeed = baseSpeed + char:GetAttribute("SpeedBuff")
    end
    local function updateJump(jump: number)
        humanoid.JumpPower = 50 + jump
    end
    local function levelReqCheck()
        if plr:GetAttribute("EXP") > Formula.EXP(plr:GetAttribute("Levels")) then
            if lvUpCD then return end

            lvUpCD = true
            Signals.LevelUp:Fire(plr)

            wait(1)
            lvUpCD = false
        end
    end

    local function clearClassAttrs()
        char:SetAttribute("Combo", 0)
        char:SetAttribute("Stack", 0)
        char:SetAttribute("Focus", 0)
        char:SetAttribute("Guard", 0)
        char:SetAttribute("RogueCri", 0)
        char:SetAttribute("Rage", 0)
        char:SetAttribute("LifeStolen", 0)
        char.AlchemistCreations:ClearAllChildren()
    end
    local function spawnProtect()
        BuffEffectsUtil:HealBuff(char, 1, 4, false)
        BuffEffectsUtil:ManaBuff(char, 1, 4)
    end

    --// Setups
    Spawn(updateMinDMG)
    Spawn(updateMaxDMG)
    Spawn(updateMagic)
    Spawn(updateShield, true)
    Spawn(updateHP)
    Spawn(updateMana, true)
    Spawn(updateSpeed)
    Spawn(updateJump, 0)
    Spawn(levelReqCheck)
    Spawn(clearClassAttrs)
    Spawn(function()
        ServerUtil:EquipWeapon(char)
    end)

    Add(HarukaLib:Hydrate(plr, {
        ["Attr-DMGPoints"] = function()
            updateMinDMG()
            updateMaxDMG()
        end,
        ["Attr-MagicPoints"] = updateMagic,
        ["Attr-HealthPoints"] = updateHP,
        ["Attr-ManaPoints"] = updateMana,
        ["Attr-ShieldPoints"] = updateShield,

        ["Attr-EXP"] = levelReqCheck,

        ["Attr-Class"] = function()
            ServerUtil:EquipWeapon(char)
        end
    }))
    Add(HarukaLib:Hydrate(char, {
        ["Attr-Mana"] = manaCheck,
        ["Attr-Shield"] = shieldCheck,

        ["Attr-MinDMGBuff"] = updateMinDMG,
        ["Attr-MaxDMGBuff"] = updateMaxDMG,
        ["Attr-MagicBuff"] = updateMagic,
        ["Attr-ShieldBuff"] = updateShield,
        ["Attr-HealthBuff"] = updateHP,
        ["Attr-ManaBuff"] = updateMana,
        ["Attr-SpeedBuff"] = updateSpeed,
        ["Attr-JumpBuff"] = updateJump,

        ["Attr-InCombat"] = function()
            ServerUtil:EquipWeapon(char)

            updateSpeed()
            clearClassAttrs()
        end,
        ["Attr-CurrentState"] = function(state: string)
            if state == "Hit" then
                shieldRepair()
                healthRecover()
            end
        end
    }))

    Spawn(spawnProtect)

    char:SetAttribute("CharDataLoaded", true)
end
Spawn(charAttributesSetup)


--// Connections
local function onDead()
    if char.PrimaryPart then
        local defeatedEff = RepS.Package.Effects.DefeatedEffect:Clone()
        defeatedEff.CFrame = char.PrimaryPart.CFrame
        defeatedEff.Parent = workspace
        Debris:AddItem(defeatedEff, 1)
    end
    char:SetAttribute("InCombat", false)

    Empty()

    for _, monsterSymbol: ObjectValue in char.CharStats.TargetMonsters:GetChildren() do
        pcall(function()
            for _, targetPlr in monsterSymbol.Value.TargetPlayers:GetChildren() do
                if targetPlr.Value == char then targetPlr:Destroy() end
            end
        end)
    end
    for _, orbFolder: Folder in workspace.MapComponents.OrbHolders:GetChildren() do
        if orbFolder.Name == char.Name then orbFolder:Destroy() end
    end
end
humanoid.Died:Once(onDead)
