--!nocheck

local story = {}

local v3New = Vector3.new

story.series = {
    {
        Name = "The Beginning",
        Target = "Talk to Cyalm",
        Desc = "",
        Hint = v3New(),
    }
}

story.sideSeries = {
    {
        Name = "Slime Troubles",
        Target = "Defeat 5 slimes",
        Desc = "",
        Hint = v3New()
    }
}

return story
