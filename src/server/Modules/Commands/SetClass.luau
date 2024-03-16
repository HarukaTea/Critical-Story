--!strict

return {
    Name = "setclass",
    Aliases = {"class"},
    Description = "Set the class to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player you wish to set"
        },
        function(context)
            return {
                Type = context.Cmdr.Util.MakeEnumType("PlayerClassType",
                { "Warrior", "Archer", "Wizard", "Knight", "Rogue", "Repeater", "Striker", "Alchemist", "Illusionist" }),
                Name = "class",
                Description = "The class you wish to get"
            }
        end
    }
}
