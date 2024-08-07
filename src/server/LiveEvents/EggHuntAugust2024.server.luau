--!nocheck

if workspace:GetAttribute("WorldType") ~= "Mainworld" then return end

local PPS = game:GetService("ProximityPromptService")
local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)


local RE = Instance.new("RemoteEvent")
RE.Name = "FindEgg"
RE.Parent = RepS.Debris

RE.OnServerEvent:Connect(function(plr: Player)
    if not plr:GetAttribute("Egg") then plr:SetAttribute("Egg", 0) end

    HarukaLib:AddAttr(plr, "Egg", 1)

    if plr:GetAttribute("Egg") >= 6 then
        Events.CreateHint.Fire(plr, { Hint = "You have found all the eggs!" })
    end
end)


local function promptsHandler(prompt: ProximityPrompt, plr: Player)
	if prompt.Name == "Teleport" then
        local destination = prompt:GetAttribute("Destination") :: string

        if destination == "Skyventure" then
            if (plr:GetAttribute("Egg") or 0) < 6 then
                Events.CreateHint.Fire(plr, { Hint = "You haven't got enough eggs!" })
                return
            end

            plr.Character:PivotTo(workspace.Maps.ArkusEnclave.Locator.CFrame)
            plr:SetAttribute("RespawnLocation", workspace.Maps.ArkusEnclave.Locator.Position)

        elseif destination == "SkyventureBack" then
            plr.Character:PivotTo(workspace.Maps.ArkusEnclave.Locator2.CFrame)
            plr:SetAttribute("RespawnLocation", nil)
        end
	end
end
PPS.PromptTriggered:Connect(promptsHandler)
