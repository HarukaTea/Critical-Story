--!strict
--!optimize 2
--!native

local sub = string.sub
local randomNew = Random.new

return function(): number?
	return tonumber(sub(tostring(randomNew():NextNumber()), 3, 6))
end
