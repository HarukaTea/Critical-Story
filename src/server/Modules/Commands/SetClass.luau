--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local ClassBook = require(RepS.Modules.Data.ClassBook)

return {
    Name = "setclass",
    Aliases = {"class"},
    Description = "Set the class of player(s)",
    Group = "Developer",
    Args = {
        {
            Type = "players",
            Name = "players",
            Description = "The player(s) who will be set"
        },
        function(context: table)
            local classes = {}
            for class: string, _ in ClassBook.ClassInfo do
                classes[#classes + 1] = class
            end

            return {
                Type = context.Cmdr.Util.MakeEnumType("GameClassesLib", classes),
                Name = "class",
                Description = "The class you wish to get"
            }
        end
    }
}
