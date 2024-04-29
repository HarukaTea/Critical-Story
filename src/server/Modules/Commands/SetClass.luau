--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)

return {
    Name = "setclass",
    Aliases = {"class"},
    Description = "Set the class to which you given.",
    Group = "Testers",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "The player who will be set"
        },
        function(context: table)
            return {
                Type = context.Cmdr.Util.MakeEnumType("PlayerClassType", AssetBook.Classes),
                Name = "class",
                Description = "The class you wish to get"
            }
        end
    }
}
