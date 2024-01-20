--!nocheck

local Players = game:GetService("Players")

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local Events = HarukaFrameworkServer.Events
local ServerUtil = HarukaFrameworkServer.ServerUtil
local SkillUtil = HarukaFrameworkServer.SkillUtil

local char = script.Parent.Parent.Parent
local plr = Players:GetPlayerFromCharacter(char)

local insert = table.insert
local floor = math.floor

local ITEM_ATTRIBUTES = { CD = 10 }

if ServerUtil:UseSkill(plr, script.Name, ITEM_ATTRIBUTES, script, true) == false then
	return
end

Events.PlaySound:Fire(plr, workspace.Sounds.SFXs.Magic1)

local nearPlayers = {}
for _, player in Players:GetPlayers() do
    if player and player.Character then
        if (char.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude <= 66 then
            insert(nearPlayers, player)
        end
    end
end
for _, player in nearPlayers do
    SkillUtil:Heal(player, floor(char.Humanoid.MaxHealth / 2))
end
