--!nocheck
--!optimize 2
--!native

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Bin = require(RepS.Modules.Packages.Bin)
local Clock = require(RepS.Modules.Packages.Clock)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local Signals = require(SSS.Modules.Data.ServerSignals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = Bin()

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)
local humanoid = char.Humanoid :: Humanoid

local isBroken = false
local lvUpCD = false

local ATTRIBUTES = require(SSS.Modules.Data.CharTemplate)

local wait = task.wait
local floor = math.floor
local instanceNew = Instance.new

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

    Add(Clock(1, function()
        HarukaLib:Add(plr, "PlayTime", 1)
    end))

    --// Spawn to the nearest respawn point
    if not RS:IsStudio() then
        local spawnPoint = ServerUtil:FindNearestSpawn(plr)

        char:PivotTo(spawnPoint.CFrame)
        plr:SetAttribute("LastLeave", spawnPoint.Position)
    end

    char:SetAttribute("CharDataLoaded", true)
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

    --- wizard
    Add(char:GetAttributeChangedSignal("InCombat"):Connect(function()
        if not char:GetAttribute("InCombat") then
            char:SetAttribute("Stack", 0)
            char:SetAttribute("Focus", 0)
            char:SetAttribute("Guard", 0)
            char:SetAttribute("RogueCri", 0)
            char:SetAttribute("TP", 0)
        end
    end))

    --- knight
    Add(Clock(1.7, function()
        if char:GetAttribute("Guard") <= 0 then return end

        HarukaLib:Add(char, "Guard", -1)
    end))

    --- Rogue
    Add(Clock(1.2, function()
        if char:GetAttribute("RogueCri") <= 0 then return end

        HarukaLib:Add(char, "RogueCri", -1)
    end))

    --- turn-base
    plr:SetAttribute("NextAction", "")
end
Spawn(classAttributesSetup)

local function charAttributesSetup()
    local function tpCheck(tp: number)
        if tp > 100 then char:SetAttribute("TP", 100) end
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
        char:SetAttribute("MinDMG", 5 + plr:GetAttribute("DMGPoints") + char:GetAttribute("MinDMGBuff"))
    end
    local function updateMaxDMG()
        char:SetAttribute("MaxDMG", 10 + (plr:GetAttribute("DMGPoints") * 2) + char:GetAttribute("MaxDMGBuff"))
    end
    local function updateMagic()
        char:SetAttribute("Magic", 10 + (plr:GetAttribute("MagicPoints") * 2) + char:GetAttribute("MagicBuff"))
    end
    local function updateShield()
        char:SetAttribute("MaxShield", 5 * plr:GetAttribute("ShieldPoints") + 5 + char:GetAttribute("ShieldBuff"))
        char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
    end
    local function updateHP()
        humanoid.MaxHealth = 50 * plr:GetAttribute("HealthPoints") + 100 + char:GetAttribute("HealthBuff")
        humanoid.Health = humanoid.MaxHealth
    end
    local function updateSpeed(speed: number)
        humanoid.WalkSpeed = 30 + speed
    end
    local function updateJump(jump: number)
        humanoid.JumpPower = 50 + jump
    end
    local function levelReqCheck()
        local level = plr:GetAttribute("Levels") :: number

        if plr:GetAttribute("EXP") >= floor(level ^ 1.85) + 60 then
            if lvUpCD then return end

            lvUpCD = true
            Signals.LevelUp:Fire(plr)

            wait(1)
            lvUpCD = false
        end
    end

    --// Setups
    Spawn(updateMinDMG)
    Spawn(updateMaxDMG)
    Spawn(updateMagic)
    Spawn(updateShield)
    Spawn(updateHP)
    Spawn(updateSpeed, 0)
    Spawn(updateJump, 0)
    Spawn(levelReqCheck)
    ServerUtil:EquipWeapon(char)

    HarukaLib:Hydrate(plr, {
        ["Attr-DMGPoints"] = function()
            updateMinDMG()
            updateMaxDMG()
        end,
        ["Attr-MagicPoints"] = updateMagic,
        ["Attr-ShieldPoints"] = updateShield,
        ["Attr-HealthPoints"] = updateHP,
        ["Attr-EXP"] = levelReqCheck,
        ["Attr-Class"] = function()
            ServerUtil:EquipWeapon(char)
        end
    })
    HarukaLib:Hydrate(char, {
        ["Attr-TP"] = tpCheck,
        ["Attr-Shield"] = shieldCheck,

        ["Attr-MinDMGBuff"] = updateMinDMG,
        ["Attr-MaxDMGBuff"] = updateMaxDMG,
        ["Attr-MagicBuff"] = updateShield,
        ["Attr-ShieldBuff"] = updateShield,
        ["Attr-HealthBuff"] = updateHP,
        ["Attr-JumpBuff"] = updateJump,

        ["Attr-InCombat"] = function()
            ServerUtil:EquipWeapon(char)
        end
    })
end
Spawn(charAttributesSetup)

--// Connections
local function onDead()
    Empty()

    if char.PrimaryPart then
        plr:SetAttribute("LastLeave", char.PrimaryPart.Position)

        local defeatedEff = RepS.Package.Effects.DefeatedEffect:Clone()
        defeatedEff.CFrame = char.PrimaryPart.CFrame
        defeatedEff.Parent = char
        Debris:AddItem(defeatedEff, 1)
    end
    char:SetAttribute("InCombat", false)

    for _, monsterSymbol in char.CharStats.TargetMonsters:GetChildren() do
        pcall(function()
            for _, targetPlr in monsterSymbol.Value.TargetPlayers:GetChildren() do
                if targetPlr.Value == char then targetPlr:Destroy() end
            end
        end)
    end

    for _, orbFolder: Folder in workspace.MapComponents.OrbFolders:GetChildren() do
        if orbFolder.Name == char.Name then orbFolder:Destroy() end
    end

    script:Destroy()
end
humanoid.Died:Once(onDead)
