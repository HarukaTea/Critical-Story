--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

--// Private

local function _addDonation(profile: table, plr: Player, amount: number)
    for _, data: table in profile.Data do data.Donation += amount end

    if plr then HarukaLib:AddAttr(plr, "Donation", amount) end
end

local extra = {
    Settings = {
        Musics = true,
        SFXs = true,
        PotatoMode = false,
        PlayerList = true,
        MapDetails = true,
        CombatMode = "Solo",
        MapShadows = true,
        TreeOptimizations = true,
        HideRole = false,
    },

    Products = {
        [1896117907] = function(profile: table, plr: Player)
            _addDonation(profile, plr, 10)
        end,
        [1896118455] = function(profile: table, plr: Player)
            _addDonation(profile, plr, 100)
        end,
        [1896276859] = function(profile: table, plr: Player)
            _addDonation(profile, plr, 500)
        end,
        [1896119027] = function(profile: table, plr: Player)
            _addDonation(profile, plr, 1000)
        end,
        [1896119593] = function(profile: table, plr: Player)
            _addDonation(profile, plr, 2500)
        end
    }
}

return extra
