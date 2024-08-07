--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local ProfileService = require(RepS.Modules.Packages.ProfileService)

local GuildLBDataStore = DSS:GetOrderedDataStore("GuildLB_CS_1599MKK40_VCA")

local profileStore = ProfileService.GetProfileStore("CS_1599MKK40_VCA")

--// Private

local function _getTop50Guilds() : table
    local isAscending = false
    local pageSize = 50
    local pages = GuildLBDataStore:GetSortedAsync(isAscending, pageSize)
    local top50 = pages:GetCurrentPage()

    local topList = {}

    for rank: number, data: table in ipairs(top50) do
        local key = data.key
        local userId = tonumber(string.sub(key, 13))
        local slotChosen = string.sub(key, 1, 6)

        table.insert(topList, rank, {
            Creator = userId,
            SlotChosen = slotChosen,
            RP = data.value
        })
    end

    return topList
end
local function _saveData(plr: Player)

end

--// Public

local function refreshLeaderboard()
    workspace.MapComponents.Guilds:ClearAllChildren()

    local top50 = _getTop50Guilds()
    for rank: number, data: table in ipairs(top50) do
        pcall(function()
            local val = Instance.new("IntValue")
            val.Name = data.Creator.."_"..data.SlotChosen
            val.Value = data.RP or 0

            val:SetAttribute("Order", rank)
            val:SetAttribute("CreatorName", Players:GetNameFromUserIdAsync(tonumber(data.Creator)))

            local profile = profileStore:ViewProfileAsync("Player_"..data.Creator)
            val:SetAttribute("GuildIcon", profile.Data[data.SlotChosen].Guild.GuildIcon)

            val.Parent = workspace.MapComponents.Guilds
        end)
    end
end
local function saveDataForServer()

end

local leaderboardFolder = Instance.new("Folder")
leaderboardFolder.Name = "Guilds"
leaderboardFolder.Parent = workspace.MapComponents

HarukaLib.Clock(60, refreshLeaderboard)
HarukaLib.Clock(45, saveDataForServer)
game:BindToClose(saveDataForServer)
Players.PlayerRemoving:Connect(_saveData)

refreshLeaderboard()
