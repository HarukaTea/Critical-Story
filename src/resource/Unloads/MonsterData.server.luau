--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local BuffEffectsUtil = require(SSS.Modules.Utils.BuffEffectsUtil)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local monster = script.Parent :: Model

local isDead = false

local wait = task.wait
local instanceNew = Instance.new
local floor = math.floor
local fromRGB = Color3.fromRGB

local function combatEnds()
    if monster.Parent:FindFirstChildOfClass("BindableEvent") then monster.Parent.CombatEnds:Fire() end

	monster.Attack.Disabled = true

    local attackFolder = monster.AttackHolder.Value :: Folder?
    local continueCombatCheck = false

    --- another issue, don't change this else it will bug
    local result = "Failed"
    if monster:GetAttribute("Health") <= 0 then result = "Success" end

    if result == "Failed" then
        ServerUtil:MonsterDefeated(monster, monster.PrimaryPart.Position, true)
        return
    end

    if result == "Success" then
        local combatPlrs, attacks = ServerUtil:GetPlayersByMonster(monster), {}

        for _, attack: Instance in attackFolder:GetDescendants() do
            if attack:IsA("BasePart") then
                if attack.Transparency < 1 then attacks[#attacks + 1] = attack end
            end
            attack:RemoveTag("MonsterDMG")
        end
        for _, player: Player in combatPlrs do
            if player then Events.ClientTween:Fire(player, attacks, { Transparency = 1 }, "one") end
        end

        for _, player: Player in combatPlrs do
            local char = player.Character
            local charStats = char.CharStats :: Folder

            --- player finished combat
            if not charStats.TargetMonsters:FindFirstChildOfClass("ObjectValue") then
                local beatList = { monster }
                for _, otherMonster: ObjectValue in monster.WaitingList:GetChildren() do
                    beatList[#beatList + 1] = otherMonster
                end

                local totalEXP = 0
                for _, defeated: Model in beatList do
                    totalEXP += defeated:GetAttribute("EXP")

                    local drop = HarukaLib:RollLoot(AssetBook.MonsterInfo[monster.Name].Drops)
	                ServerUtil:GiveItem(player, drop, 1)
                end

                HarukaLib:AddAttr(player, "EXP", totalEXP)
                HarukaLib:AddAttr(player, "Gold", floor(totalEXP / 2))
                HarukaLib:AddAttr(player, "RP", floor(totalEXP / 6))

                ServerUtil:ShowText(char, "+" .. totalEXP .. " EXP", fromRGB(245, 205, 48))
                ServerUtil:ShowText(char, "+" .. floor(totalEXP / 1.5) .. " Gold", fromRGB(255, 255, 127))
                ServerUtil:ShowText(char, "+" .. floor(totalEXP / 6) .. " RP", fromRGB(0, 255, 255))

                --// Clear
                char:SetAttribute("InCombat", false)
                charStats.TargetMonster.Value = nil

                BuffEffectsUtil:PurifyBuff(char)

                for _, orbFolder: Folder in workspace.MapComponents.OrbHolders:GetChildren() do
                    if orbFolder.Name == player.Name then orbFolder:Destroy() end
                end

                continue
            end

            --- if still doesn't finished, then target next one
            charStats.TargetMonster.Value = charStats.TargetMonsters:FindFirstChildOfClass("ObjectValue").Value
        end

        local realLocator: BasePart = if monster:GetAttribute("SubMonster") then monster.Parent.Parent else monster.Parent
        for _, child: Instance in realLocator:GetDescendants() do
            if child:HasTag("Monster")
                and child ~= monster
                and child:GetAttribute("InCombat")
                and child:GetAttribute("Health") > 0 then

                if child:FindFirstChild("TargetPlayers")
                    and child.TargetPlayers:FindFirstChildOfClass("ObjectValue") then

                    continueCombatCheck = true

                    local locatorSymbol = instanceNew("ObjectValue")
                    locatorSymbol.Name = monster.Name
                    locatorSymbol.Value = monster.Parent
                    locatorSymbol:SetAttribute("EXP", monster:GetAttribute("EXP"))
                    locatorSymbol.Parent = child.WaitingList

                    for _, pastWaiting: ObjectValue in monster.WaitingList:GetChildren() do
                        pastWaiting.Parent = child.WaitingList
                    end
                    break
                end
            end
        end

        ServerUtil:MonsterDefeated(monster, monster.PrimaryPart.Position, not continueCombatCheck)
    end
end

HarukaLib:Hydrate(monster, {
    ["Attr-Health"] = function(newHP: number)
        monster.Head.Display.Number.Text = newHP

        if newHP < 0 then monster.Head.Display.Number.Text = "0" end
		if newHP <= 0 and not isDead then
			isDead = true

			monster:SetAttribute("Health", 0)

			pcall(function()
				for _, char: Player in monster.TargetPlayers:GetChildren() do
					for _, targetMonster in char.Value.CharStats.TargetMonsters:GetChildren() do
						if targetMonster.Value == monster then targetMonster:Destroy() end
					end
				end
			end)

			combatEnds()
		end
    end
})
monster.TargetPlayers.ChildRemoved:Connect(function()
    wait()
    if not monster.TargetPlayers:FindFirstChildOfClass("ObjectValue") and not isDead then
        isDead = true

        combatEnds()
    end
end)
