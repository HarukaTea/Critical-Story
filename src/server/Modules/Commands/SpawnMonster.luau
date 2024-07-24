--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local MonsterBook = require(RepS.Modules.Data.MonsterBook)

return {
    Name = "spawnmonster",
    Aliases = {"spawnmob"},
    Description = "Spawn a monster at where you stand.",
    Group = "Developer",
    Args = {
        function(context: table)
            local monsters = {}
            for monster: string, _ in MonsterBook do
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
            Description = "The level you want to fight, max is 1100",
            Default = 1
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of monsters you wanna fight in a single combat, max is 5",
            Default = 1
        },
        {
            Type = "boolean",
            Name = "respawnable",
            Description = "Whether or not the monster should respawn after it dies",
            Default = false
        }
    }
}
