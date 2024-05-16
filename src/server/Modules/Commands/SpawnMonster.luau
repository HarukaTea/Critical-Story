--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)

return {
    Name = "spawnmonster",
    Aliases = {"spawnmob"},
    Description = "Spawns a monster at where you stand.",
    Group = "Testers",
    Args = {
        function(context: table)
            local monsters = {}
            for monster: string, _ in AssetBook.MonsterInfo do
                monsters[#monsters + 1] = monster
            end

            return {
                Type = context.Cmdr.Util.MakeEnumType("GameMonstersLib", monsters),
                Name = "monster",
                Description = "The monster you wish to spawn"
            }
        end,
        {
            Type = "number",
            Name = "level",
            Description = "The level you want to fight, max is 950",
            Default = 1
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of monsters you wanna fight in a single combat, max is 5",
            Default = 1
        }
    }
}
