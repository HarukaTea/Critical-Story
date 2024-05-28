--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Shared = script:WaitForChild("Shared")
local Util = require(Shared:WaitForChild("Util"))

if RunService:IsClient() == false then
	error(
		"[Cmdr] Server scripts cannot require the client library. Please require the server library from the server to use Cmdr in your own code."
	)
end

local Cmdr
do
	Cmdr = setmetatable({
		ReplicatedRoot = script,
		RemoteFunction = script:WaitForChild("CmdrFunction"),
		RemoteEvent = script:WaitForChild("CmdrEvent"),
		ActivationKeys = { [Enum.KeyCode.F2] = true },
		Enabled = true,
		MashToEnable = false,
		ActivationUnlocksMouse = false,
		HideOnLostFocus = true,
		PlaceName = "Cmdr",
		Util = Util,
		Events = {},
	}, {
		-- This sucks, and may be redone or removed
		-- Proxies dispatch methods on to main Cmdr object
		__index = function(self, k)
			local r = self.Dispatcher[k]
			if r and type(r) == "function" then
				return function(_, ...)
					return r(self.Dispatcher, ...)
				end
			end
		end,
	})

	Cmdr.Registry = require(Shared.Registry)(Cmdr)
	Cmdr.Dispatcher = require(Shared.Dispatcher)(Cmdr)
end

-- create gui
ReplicatedStorage.Package.Unloads.Cmdr:Clone().Parent = Players.LocalPlayer.PlayerGui

local Interface = require(script.CmdrInterface)(Cmdr)

--[=[
	Sets the key codes that will used to show or hide Cmdr.

	@within CmdrClient
]=]
function Cmdr:SetActivationKeys(keys: { Enum.KeyCode })
	self.ActivationKeys = Util.MakeDictionary(keys)
end

--[=[
	Sets the place name label on the interface. This is useful for a quick way to tell what game you're playing in a universe game.

	@within CmdrClient
]=]
function Cmdr:SetPlaceName(name: string)
	self.PlaceName = name
	Interface.Window:UpdateLabel()
end

--[=[
	Sets whether or not Cmdr can be shown via the defined activation keys. Useful for when you want users to opt-in to show the console, for instance in a settings menu.

	@within CmdrClient
]=]
function Cmdr:SetEnabled(enabled: boolean)
	self.Enabled = enabled
end

--[=[
	Sets if activation will free the mouse.

	@within CmdrClient
]=]
function Cmdr:SetActivationUnlocksMouse(enabled: boolean)
	self.ActivationUnlocksMouse = enabled
end

--[=[
	Shows the Cmdr window. Does nothing if Cmdr isn't enabled.

	@within CmdrClient
]=]
function Cmdr:Show()
	if not self.Enabled then
		return
	end

	Interface.Window:Show()
end

--[=[
	Hides the Cmdr window.

	@within CmdrClient
]=]
function Cmdr:Hide()
	Interface.Window:Hide()
end

--[=[
	Toggles the Cmdr window. Does nothing if Cmdr isn't enabled.

	@within CmdrClient
]=]
function Cmdr:Toggle()
	if not self.Enabled then
		self:Hide()
		return
	end

	Interface.Window:SetVisible(not Interface.Window:IsVisible())
end

--[=[
	Enables the "Mash to open" feature.
	This feature, when enabled, requires the activation key to be pressed 5 times within a second to [enable](#SetEnabled) Cmdr.
	This may be helpful to guard against mispresses from opening the window, for example.

	@within CmdrClient
]=]
function Cmdr:SetMashToEnable(enabled: boolean)
	self.MashToEnable = enabled

	if enabled then
		self:SetEnabled(false)
	end
end

--[=[
	Sets the hide on 'lost focus' feature.
	This feature, which is enabled by default, will cause Cmdr to [hide](#Hide) when the user clicks off the window.

	@within CmdrClient
]=]
function Cmdr:SetHideOnLostFocus(enabled: boolean)
	self.HideOnLostFocus = enabled
end

--[=[
	Sets the [network event handler](/docs/networkeventhandlers) for a certain event type.

	@within CmdrClient
]=]
function Cmdr:HandleEvent(name: string, callback: (...any) -> ())
	self.Events[name] = callback
end

-- "Only register when we aren't in studio because don't want to overwrite what the server portion did"
-- This is legacy code which predates Accurate Play Solo (which is now the only way to test in studio), this code will never run.
if RunService:IsServer() == false then
	Cmdr.Registry:RegisterTypesIn(script:WaitForChild("Types"))
	Cmdr.Registry:RegisterCommandsIn(script:WaitForChild("Commands"))
end

-- Hook up event listener
Cmdr.RemoteEvent.OnClientEvent:Connect(function(name, ...)
	if Cmdr.Events[name] then
		Cmdr.Events[name](...)
	end
end)

require(script.DefaultEventHandlers)(Cmdr)

return Cmdr
