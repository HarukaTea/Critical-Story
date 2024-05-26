--!nocheck

local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)

return function (context: table, player: string)
    local check = pcall(function()
        assert(type(player) == "string")
    end)

    if not check then return "Wrong player username!" end

    local playerId: number
    local check2 = pcall(function()
        playerId = Players:GetUserIdFromNameAsync(player)
    end)

    if not check2 then return "Player not found!" end

    local connection: RBXScriptConnection
    task.spawn(function()
        task.wait(5)
        if connection then
            connection:Disconnect()

            Events.CreateHint:Fire(context.Executor, "Player not in this game!")
        end
    end)

    connection = MessagingService:SubscribeAsync("JoinUserReturn", function(message: table)
        if message.Data[1] == playerId then
            local joinData = context.Executor:GetJoinData().TeleportData :: table?
            local slotChosen = if joinData then joinData[1] else "Slot1"

            local teleportOptions = Instance.new("TeleportOptions")

            teleportOptions:SetTeleportData({ slotChosen })
            teleportOptions.ServerInstanceId = message.Data[2]

            TeleportService:TeleportAsync(message.Data[3], { context.Executor }, teleportOptions)

            connection:Disconnect()
        end
    end)

    MessagingService:PublishAsync("JoinUserRequest", playerId)

    return "Teleporting..."
end