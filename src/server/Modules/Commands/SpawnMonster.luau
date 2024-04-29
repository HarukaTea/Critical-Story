--!nocheck
--!optimize 2
--!native

return {
    Name = "spawnmonster",
    Aliases = {"spawnmob"},
    Description = "Spawns a monster at where you stand.",
    Group = "Testers",
    Args = {
        {
            Type = "string",
            Name = "monster",
            Description = "The monster you want to spawn"
        },
        {
            Type = "number",
            Name = "level",
            Description = "The level you want to fight",
            Default = 1
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of monsters you wanna fight in a single combat, max is 4",
            Default = 1
        }
    }
}
