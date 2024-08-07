--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local DonationLBDataStore = DSS:GetOrderedDataStore("DonationLB_CS_1599MKK40_VCA")

--// Private

local function _getTop50Players() : table
    local isAscending = false
    local pageSize = 50
    local pages = DonationLBDataStore:GetSortedAsync(isAscending, pageSize)
    local top50 = pages:GetCurrentPage()

    local topList = {}

    for rank: number, data: table in ipairs(top50) do
        local key = data.key
        local userId = tonumber(string.sub(key, 8))

        table.insert(topList, rank, { PlayerId = userId, Donation = data.value })
    end

    return topList
end
local function _saveData(plr: Player)
    local donation = plr:GetAttribute("Donation") :: number

    local ok, err = pcall(function()
        DonationLBDataStore:SetAsync("Player_"..plr.UserId, donation)
    end)
    if not ok then print(err) end
end

--// Public

local function refreshLeaderboard()
    workspace.MapComponents.Donations:ClearAllChildren()

    local top50 = _getTop50Players()
    for rank: number, data: table in ipairs(top50) do
        pcall(function()
            local val = Instance.new("IntValue")
            val.Name = data.PlayerId
            val.Value = data.Donation or 0
            val:SetAttribute("Order", rank)
            val:SetAttribute("PlayerName", Players:GetNameFromUserIdAsync(tonumber(data.PlayerId)))
            val:SetAttribute("AvatarImage", Players:GetUserThumbnailAsync(tonumber(data.PlayerId), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48))
            val.Parent = workspace.MapComponents.Donations
        end)
    end
end
local function saveDataForServer()
    for _, plr: Player in Players:GetPlayers() do
        _saveData(plr)
    end
end

local leaderboardFolder = Instance.new("Folder")
leaderboardFolder.Name = "Donations"
leaderboardFolder.Parent = workspace.MapComponents

HarukaLib.Clock(60, refreshLeaderboard)
HarukaLib.Clock(45, saveDataForServer)
game:BindToClose(saveDataForServer)
Players.PlayerRemoving:Connect(_saveData)

refreshLeaderboard()
