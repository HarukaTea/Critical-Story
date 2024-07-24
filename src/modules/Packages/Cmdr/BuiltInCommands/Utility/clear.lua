local Players = game:GetService("Players")

return {
	Name = "cls",
	Aliases = {},
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "Player",
	Args = {},
	ClientRun = function()
		local player = Players.LocalPlayer
		local gui = player.PlayerGui.Cmdr
		local frame = gui.Frame

		if gui and frame then
			for _, child in pairs(frame:GetChildren()) do
				if child.Name == "Line" and child:IsA("TextBox") then
					child:Destroy()
				end
			end
		end
		return ""
	end,
}
