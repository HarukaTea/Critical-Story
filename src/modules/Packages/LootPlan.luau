--!strict

local LootPlan = {}
LootPlan.prototype = {}
LootPlan.__index = LootPlan.prototype

local insert, clear, sort, freeze = table.insert, table.clear, table.sort, table.freeze
local randomNew = Random.new

--// Private

function LootPlan.prototype:_UpdateLootList()
	if self._ListUpdated == true then
		return
	end

	self._ListUpdated = true

	clear(self.LootList)

	for _, loot in self.Loot do
		insert(self.LootList, loot)
	end

	sort(self.LootList, function(a, b)
		return a.Weight < b.Weight
	end)
end

--// Public

--[[
	Create a new lootplan object, and waiting for RNG
]]
function LootPlan.new()
	local plan = {}

	plan.Randomiser = randomNew()
	plan.Loot = {}
	plan.LootList = {}
	plan.LootCount = 0
	plan.TotalChance = 0
	plan._ListUpdated = true

	setmetatable(plan, LootPlan)

	return plan
end


--[=[
	Get the percentage chance of a loot. This is calculated as a simple
	division to find percentage `(x/total) * 100`.
]=]
function LootPlan.prototype:GetChance(name: string): number
	local loot = self.Loot[name]

	if not loot then
		error("No loot with name \"" .. name .. "\"")
	end

	return (loot.Weight/self.TotalChance) * 100
end

--[=[
	Adds a piece of loot to the loot table.
]=]
function LootPlan.prototype:Add(name: string, weight: number)
	assert(typeof(name) == "string", "A string is expected for Add arg #1")

	local newLoot = {
		Name = name,
		Weight = weight,
	}

	self.Loot[name] = newLoot
	self.LootCount += 1
	self.TotalChance += weight

	self._ListUpdated = false
end

--[=[
	Removes a piece of loot from the loot table.
]=]
function LootPlan.prototype:Remove(name: string)
	local loot = self.Loot[name]
	if not loot then return end

	self.TotalChance -= loot.Weight
	self.LootCount -= 1
	self.Loot[name] = nil

	self._ListUpdated = false
end

--[=[
	Changes the weight of a loot.
]=]
function LootPlan.prototype:ChangeWeight(name: string, weight: number)
	local loot = self.Loot[name]

	if not loot then
		error("No loot with name \"" .. name .. "\"")
	end

	self.TotalChance += weight - loot.Weight
	loot.Weight = weight

	self._ListUpdated = false
end

--[=[
	Rolls for a random piece of loot from the loot table

	```lua
	local result = plan:Roll()

	if result ~= "Rare" then
		-- Handle a positive result
	end
	```
]=]
function LootPlan.prototype:Roll(): string
	self:_UpdateLootList()

	local result = self.Randomiser:NextNumber()
	local aggregate = 0

	for _, loot in self.LootList do
		local chance = loot.Weight

		if result < (chance + aggregate)/self.TotalChance then
			return loot.Name
		end

		aggregate += chance
	end
end

--[=[
	Cleans up the LootPlan object and locks the table from changes.
]=]
function LootPlan.prototype:Destroy()
	clear(self)
	freeze(self)
end

return LootPlan
