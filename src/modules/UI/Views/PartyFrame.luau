--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local PartyInviteSlot = require(RepS.Modules.UI.Components.PartyInviteSlot)

local Children, New, Computed, OnChange, Value, peek =
	Fusion.Children, Fusion.New, Fusion.Computed, Fusion.OnChange, Fusion.Value, Fusion.peek

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local insert, tFind, remove = table.insert, table.find, table.remove
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local wait = task.wait

local function Title(index: number, text: string) : TextLabel
	return Components.TextLabel({
		Name = "Title"..index,
		Position = if index == 1 then fromScale(0, 0) else fromScale(0.416, 0),
		Size = fromScale(0.355, 0.1),
		TextColor3 = fromRGB(255, 170, 127),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "<u>"..text.."</u>",
		RichText = true
	})
end
local function Tip(index: number, text: string, self: table) : TextLabel
	return Components.TextLabel({
		Name = "Tip"..index,
		Position = if index == 1 then fromScale(0.027, 0.438) else fromScale(0.536, 0.438),
		Size = fromScale(0.298, 0.107),
		Text = text,
		TextTransparency = 0.5,

		Visible = Computed(function(use)
			if index == 1 then
				if not use(self.players)[1] then return true else return false end
			elseif index == 2 then
				if not use(self.partyMembers)[1] then return true else return false end
			end
		end)
	})
end

local function PartyFrame(self: table): Frame
	local camera = workspace.CurrentCamera
	self.absCamSize = Value({ camera.ViewportSize.X * 0.944 * 0.579, camera.ViewportSize.Y * 0.627 * 0.883 })
	self.absCellSize = Value({ peek(self.absCamSize)[1] * 0.48, peek(self.absCamSize)[2] * 0.15 })
	self.absSize = { Value(0), Value(0) }
	self.absContentSize = { Value(0), Value(0) }
	self.players = Value({})
	self.partyMembers = Value({})

	local function _setNewPlayers()
		local reqPlayers = {}
		for _, player in Players:GetPlayers() do
			if player == self.plr then continue end

			insert(reqPlayers, player)
		end

		self.players:set(reqPlayers)
	end
	_setNewPlayers()
	Players.PlayerAdded:Connect(_setNewPlayers)
	Players.PlayerRemoving:Connect(_setNewPlayers)

	local function _setPartyMembers(added: Folder | ObjectValue, method: string)
		wait()
		local plr = self.plr :: Player

		if method == "Add" then
			if workspace.MapComponents.Parties:FindFirstChild(plr.Name, true) then
				if added:IsA("ObjectValue") and added.Parent:FindFirstChild(plr.Name) then
					self.partyMembers:set(added.Parent:GetChildren())
				end
			end
		end
		if method == "Remove" then
			if added.Name == plr.Name and added:IsA("ObjectValue") then self.partyMembers:set({}) end
			if added:IsA("ObjectValue") then
				local members = peek(self.partyMembers)
				if tFind(members, added) then
					remove(members, tFind(members, added))
				end

				self.partyMembers:set(members)
			end
		end
		if method == "Refresh" then
			local check = workspace.MapComponents.Parties:FindFirstChild(plr.Name, true)

			if not check then return end

			if check:IsA("Folder") then
				self.partyMembers:set(check:GetChildren())

			elseif check:IsA("ObjectValue") then
				self.partyMembers:set(check.Parent:GetChildren())
			end
		end
	end
	_setPartyMembers(nil, "Refresh")
	Fusion.Hydrate(workspace:WaitForChild("MapComponents").Parties)({
		[Fusion.OnEvent("DescendantAdded")] = function(added)
			_setPartyMembers(added, "Add")
		end,
		[Fusion.OnEvent("DescendantRemoving")] = function(added)
			_setPartyMembers(added, "Remove")
		end
	})
	Fusion.Hydrate(camera)({
		[Fusion.OnChange("ViewportSize")] = function(newSize)
			self.absCamSize:set({ newSize.X * 0.944 * 0.579, newSize.Y * 0.627 * 0.883 })
			self.absCellSize:set({ peek(self.absCamSize)[1] * 0.48, peek(self.absCamSize)[2] * 0.15 })
		end,
	})

	return Components.Frame({
		Name = "Party",
		Position = fromScale(0.496, 0.567),
		Size = fromScale(0.944, 0.627),
		Visible = false,

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 3.856 }),

			Title(1, "Players"),
			Title(2, "Your Party"),

			Tip(1, "NO PLAYERS IN SERVER", self),
			Tip(2, "NO PARTY CREATED", self),

			Components.ScrollingFrame({
				Name = "InviteList",
				AnchorPoint = v2New(),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Position = fromScale(0, 0.133),
				Size = fromScale(0.363, 0.883),
				ClipsDescendants = true,
				CanvasSize = Computed(function(use)
					if use(self.absContentSize[1]) > use(self.absSize[1]) then
						return fromOffset(0, use(self.absContentSize[1]))
					else
						return fromOffset(0, 0)
					end
				end),
				ScrollingEnabled = Computed(function(use)
					return if use(self.absContentSize[1]) > use(self.absSize[1]) then true else false
				end),

				[Fusion.Ref] = self.partyInvList,
				[OnChange("AbsoluteSize")] = function(newSize: UDim)
					self.absSize[1]:set(newSize.Y)
				end,

				[Children] = {
					New("UIListLayout")({
						Padding = udNew(0, 6),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,

						[OnChange("AbsoluteContentSize")] = function(newSize: UDim)
							self.absContentSize[1]:set(newSize.Y)
						end
					}),
					Fusion.ForValues(self.players, function(use, player: Player)
						return PartyInviteSlot(player, "Invite", self)
					end, Fusion.cleanup)
				}
			}),
			Components.ScrollingFrame({
				Name = "MembersList",
				AnchorPoint = v2New(),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Position = fromScale(0.416, 0.133),
				Size = fromScale(0.579, 0.883),
				ClipsDescendants = true,
				CanvasSize = Computed(function(use)
					if use(self.absContentSize[2]) > use(self.absSize[2]) then
						return fromOffset(0, use(self.absContentSize[2]))
					else
						return fromOffset(0, 0)
					end
				end),
				ScrollingEnabled = Computed(function(use)
					return if use(self.absContentSize[2]) > use(self.absSize[2]) then true else false
				end),

				[Fusion.Ref] = self.partyMembersList,
				[OnChange("AbsoluteSize")] = function(newSize: UDim)
					self.absSize[2]:set(newSize.Y)
				end,

				[Children] = {
					New("UIGridLayout")({
						CellPadding = fromOffset(8, 8),
						CellSize = Computed(function(use)
							return fromOffset(use(self.absCellSize)[1], use(self.absCellSize)[2])
						end),

						[OnChange("AbsoluteContentSize")] = function(newSize: UDim)
							self.absContentSize[2]:set(newSize.Y)
						end
					}),
					Fusion.ForValues(self.partyMembers, function(use, objVal: ObjectValue)
						return PartyInviteSlot(objVal.Value, "Member", self)
					end, Fusion.cleanup)
				}
			}),
		},
	})
end

return PartyFrame
