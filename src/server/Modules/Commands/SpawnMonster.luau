--!nocheck
--!optimize 2
--!native

return {
    Name = "spawnmonster",
    Aliases = {"spawn"},
    Description = "Spawns Spike Fox at where you stand.",
    Group = "Testers",
    Args = {
        {
            Type = "number",
            Name = "level",
            Description = "The level you want to fight"
        },
        {
            Type = "number",
            Name = "amount",
            Description = "The amount of monsters you wanna fight in a single combat, max is 10",
            Default = 1
        }
    }
}
