--!nocheck

local Players = game:GetService("Players")

local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)
local SkillUtil = require(SSS.Modules.Utils.SkillUtil)

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
