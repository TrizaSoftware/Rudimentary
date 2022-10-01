local Ruact = require(script.Parent.Ruact)
local Dependencies = script:WaitForChild("Dependencies")
local Signal = require(Dependencies.Signal)
local _warn = warn
local function warn(...)
    _warn("[Rudimentary Client / Button Engine]:",...)
end

local ValidStyles = {
    "Outlined",
    "Contained",
    "Regular"
}

local Button = {}
local Properties = {
	["Color"] = function(self, color)

	end,
	["Icon"] = function(self, iconName)

	end,
    ["Style"] = function(self, style)
        assert(table.find(ValidStyles, style), string.format("%s isn't a valid StyleType.", style))
        assert(self.Style ~= style, string.format("This button's style is already %s.", style))
        if style == "Outlined" then
            
        end
    end,
    ["Text"] = function(self, text)
        self.Button.Text = text
    end,
    ["Size"] = function(self, size)
        assert(typeof(size) == "UDim2", "Size must be a UDim2 value.")
        self.Button.Size = size
    end,
    ["Position"] = function(self, position)
        assert(typeof(position) == "UDim2", "Position must be a UDim2 value.")
        self.Button.Position = position
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
    self.Style = "Regular"
    self.Button = Ruact.new("TextButton", {
    })
    self.ButtonText = Ruact.new("TextLabel", {
        Parent = Button,
        TextScaled = true,
        Size = UDim2.new(1,0,1,0)
    })
    Ruact.new("UITextSizeConstraint", {
        MaxTextSize = 30,
        MinTextSize = 10,
        Parent = self.ButtonText
    })
    Ruact.new("UICorner", {
        CornerRadius = Vector2.new(0,10),
        Parent = self.Button
    })
	self.Clicked = Signal.new()
	return setmetatable(self, Button)
end

return Button