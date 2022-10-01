local Client = nil
local Ruact = require(script.Parent.Ruact)
local Icons = require(script.Parent.MaterialIcons)
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

local function clearStyleData(button)
    button.BackgroundColor3 = Client.UI.GetFolderForElement("PrimaryButtonColor")
    for _, item:Instance in button:GetChildren() do
        if item:IsA("UIStroke") and item:GetAttribute("ButtonStyleItem") then
            item:Destroy()
        end
    end
end

local Button = {}
local Properties = {
	["Color"] = function(self, color)
        assert(typeof(color) == "Color3", "Color must be a valid Color3 value.")
        self.ButtonText.TextColor3 = color

	end,
	["Icon"] = function(self, iconName:string)
        assert(Icons[iconName], string.format("%s isn't a valid icon.", iconName))
	end,
    ["Style"] = function(self, style)
        assert(table.find(ValidStyles, style), string.format("%s isn't a valid StyleType.", style))
        assert(self.Style ~= style, string.format("This button's style is already %s.", style))
        clearStyleData(self.Button)
        if style == "Outlined" then
            local UIStroke = Ruact.new("UIStroke", {
                
            })
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
    end,
    ["Parent"] = function(self, parent)
        assert(typeof(parent) == "Instance", "A button can only be parented to an instance.")
        self.Button.Parent = parent
    end
}
Button.__index = Button
Button.__newindex = function(self, index, value)
	assert(Properties[index], string.format("%s isn't a valid property.", index))
	local suc, result = pcall(Properties[index], self, value)
	if not suc then warn(result) else return result end
end

function Button.new(Client)
    Client = Client
	local self = {}
    self.Style = "Regular"
    self.Button = Ruact.new("TextButton", {
        BackgroundTransparency = 1
    })
    self.ButtonText = Ruact.new("TextLabel", {
        Font = Enum.Font.Gotham,
        Parent = self.Button,
        TextScaled = true,
        Size = UDim2.new(1,0,1,0)
    })
    Ruact.new("UITextSizeConstraint", {
        MaxTextSize = 20,
        MinTextSize = 10,
        Parent = self.ButtonText
    })
    Ruact.new("UICorner", {
        CornerRadius = UDim.new(0,10),
        Parent = self.Button
    })
	self.Clicked = Signal.new()
	return setmetatable(self, Button)
end

return Button