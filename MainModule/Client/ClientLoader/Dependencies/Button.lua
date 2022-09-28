local Button = {}
local Properties = {
	["Color"] = function(self, color)

	end
}
Button.__index = Button
Button.__newindex = function(self, index, value)
	assert(Properties[index], string.format("%s isn't a valid property.", index))
	local suc, result = pcall(Properties[index], self, value)
	if not suc then warn(result) else return result end
end

function Button.new()
	local self = {}

	return setmetatable(self, Button)
end

return Button