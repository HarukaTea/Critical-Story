--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
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
local v3New = Vector3.new
local cfNew = CFrame.new

repeat wait() until plr:GetAttribute("PlayerDataLoaded")

local function setup()
    char.PrimaryPart = char.Humanoid.RootPart

    local function _createFolder(name: string, parent: Folder) : Folder
        local folder = instanceNew("Folder")
        folder.Name = name
        folder.Parent = parent

        return folder
    end
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

    Add(HarukaLib.Clock(1, function()
        HarukaLib:Add(plr, "PlayTime", 1)

        if char:GetAttribute("HitCD") >= 0 then HarukaLib:Add(char, "HitCD", -1) end
    end))

    char:SetAttribute("CharDataLoaded", true)

    --// Spawn to the nearest respawn point
    if not RS:IsStudio() then
        if plr:GetAttribute("RespawnLocation") ~= v3New() then char:PivotTo(cfNew(plr:GetAttribute("RespawnLocation"))) end
    end
end
Spawn(setup)

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

    --- knight
    Add(HarukaLib.Clock(1, function()
        if char:GetAttribute("Guard") <= 0 then return end

        HarukaLib:Add(char, "Guard", -1)
    end))

    --- Rogue
    Add(HarukaLib.Clock(0.6, function()
        if char:GetAttribute("RogueCri") <= 0 then return end

        HarukaLib:Add(char, "RogueCri", -1)
    end))
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

        if shield <= 0 and not isBroken then
            isBroken = true

            Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.ShieldBroken)
        end
    end

    local function updateMinDMG()
        char:SetAttribute("MinDMG", 5 + plr:GetAttribute("DmgPoints") + char:GetAttribute("MinDMGBuff"))
    end
    local function updateMaxDMG()
        char:SetAttribute("MaxDMG", 15 + (plr:GetAttribute("DmgPoints") * 2) + char:GetAttribute("MaxDMGBuff"))
    end
    local function updateMagic()
        char:SetAttribute("Magic", 10 + (plr:GetAttribute("MagicPoints") * 2) + char:GetAttribute("MagicBuff"))
    end
    local function updateShield()
        char:SetAttribute("MaxShield", 20 * plr:GetAttribute("ShieldPoints") + 20 + char:GetAttribute("ShieldBuff"))
        char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
    end
    local function updateMana()
        char:SetAttribute("MaxMana", floor(plr:GetAttribute("ManaPoints") * 20) + 100 + char:GetAttribute("ManaBuff"))
        char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
    end
    local function updateHP()
        humanoid.MaxHealth = 50 * plr:GetAttribute("HealthPoints") + 100 + char:GetAttribute("HealthBuff")
        humanoid.Health = humanoid.MaxHealth
    end
    local function updateSpeed()
        local baseSpeed = if char:GetAttribute("InCombat") then 30 else 40

        humanoid.WalkSpeed = baseSpeed + char:GetAttribute("SpeedBuff")
    end
    local function updateJump(jump: number)
        humanoid.JumpPower = 50 + jump
    end
    local function levelReqCheck()
        local level = plr:GetAttribute("Levels") :: number

        if plr:GetAttribute("EXP") >= floor(level ^ 1.65) + 49 then
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
    end

    --// Setups
    Spawn(updateMinDMG)
    Spawn(updateMaxDMG)
    Spawn(updateMagic)
    Spawn(updateShield)
    Spawn(updateHP)
    Spawn(updateMana)
    Spawn(updateSpeed)
    Spawn(updateJump, 0)
    Spawn(levelReqCheck)
    Spawn(clearClassAttrs)
    Spawn(function()
        ServerUtil:EquipWeapon(char)
    end)

    Add(HarukaLib:Hydrate(plr, {
        ["Attr-DmgPoints"] = function()
            updateMinDMG()
            updateMaxDMG()
        end,
        ["Attr-MagicPoints"] = updateMagic,
        ["Attr-ShieldPoints"] = updateShield,
        ["Attr-HealthPoints"] = updateHP,
        ["Attr-ManaPoints"] = updateMana,

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
        end
    }))
end
Spawn(charAttributesSetup)

--// Connections
local function onDead()
    if char.PrimaryPart then
        local defeatedEff = RepS.Package.Effects.DefeatedEffect:Clone()
        defeatedEff.CFrame = char.PrimaryPart.CFrame
        defeatedEff.Parent = char
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
