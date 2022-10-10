local Client = nil
local TweenService = game:GetService("TweenService")
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

local Button = {}
local Properties = {
	["Color"] = function(self, color)
        assert(typeof(color) == "Color3", "Color must be a valid Color3 value.")
        if not self.TextColor then
            self.ButtonText.TextColor3 = color
        end
        if self.Button:FindFirstChildWhichIsA("UIStroke") then
            self.Button.UIStroke.Color = color
        end
        self:setValue("Color", color)
	end,
    ["TextColor"] = function(self, color)
        assert(typeof(color) == "Color3", "TextColor must be a valid Color3 value.")
        self.ButtonText.TextColor3 = color
        self:setValue("TextColor", color)
    end,
	["Icon"] = function(self, iconName:string)
        assert(Icons[iconName], string.format("%s isn't a valid icon.", iconName))
	end,
    ["Style"] = function(self, style)
        assert(table.find(ValidStyles, style), string.format("%s isn't a valid StyleType.", style))
        assert(self.Style ~= style, string.format("This button's style is already %s.", style))
        self:clearStyleData()
        self:setValue("Style", style)
        if style == "Outlined" then
            local UIStroke = Ruact.new("UIStroke", {
                Thickness = 1,
                Parent = self.Button,
                Color = self.Color or Color3.fromRGB(58, 87, 150),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            })
            UIStroke:SetAttribute("ButtonStyleItem", true)
        elseif style == "Contained" then
            self.Button.BackgroundTransparency = 0
            rawset(self, "RegularTransparency", 0)
        end
    end,
    ["Text"] = function(self, text)
        self.ButtonText.Text = text
        self:setValue("Text", text)
    end,
    ["Size"] = function(self, size)
        assert(typeof(size) == "UDim2", "Size must be a UDim2 value.")
        self.Button.Size = size
        self:setValue("Size", size)
    end,
    ["Position"] = function(self, position)
        assert(typeof(position) == "UDim2", "Position must be a UDim2 value.")
        self.Button.Position = position
        self:setValue("Position", position)
    end,
    ["Parent"] = function(self, parent)
        assert(typeof(parent) == "Instance", "A button can only be parented to an instance.")
        self.Button.Parent = parent
        self:setValue("Parent", parent)
    end
}
Button.__index = function(self, index, ...)
    if not Button[index] then
        return self.Values[index]
    else
        return Button[index]
    end
end
Button.__newindex = function(self, index, value)
	assert(Properties[index], string.format("%s isn't a valid property.", index))
	local suc, result = pcall(Properties[index], self, value)
	if not suc then warn(result) else return result end
end

function Button.new(Clnt)
    Client = Clnt

    -- Initialize Class

	local self = setmetatable({}, Button)
    rawset(self, "Values", {})
    rawset(self, "Button",  Ruact.new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    }))
    rawset(self, "ButtonText", Ruact.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Parent = self.Button,
        TextScaled = true,
        Size = UDim2.new(1,0,1,0)
    }))
    rawset(self, "Clicked", Signal.new())
    Ruact.new("UITextSizeConstraint", {
        MaxTextSize = 20,
        MinTextSize = 10,
        Parent = self.ButtonText
    })
    Ruact.new("UICorner", {
        CornerRadius = UDim.new(0,5),
        Parent = self.Button
    })

    -- Handle Animations

    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{BackgroundTransparency = 0.6}):Play()
    end)

    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{BackgroundTransparency = self.RegularTransparency}):Play()
    end)

    self.Button.MouseButton1Down:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{BackgroundTransparency = 0.4}):Play()
    end)

    self.Button.MouseButton1Up:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{BackgroundTransparency = 0.6}):Play()
    end)

    -- Handle Click

    self.Button.MouseButton1Click:Connect(function()
        self.Clicked:Fire()
    end)

    -- Set Style

    self.Style = "Regular"
	return self
end

function Button:setValue(item, value)
    self.Values[item] = value
end

function Button:clearStyleData()
    self.Button.BackgroundColor3 = self.Color or Color3.fromRGB(58, 87, 150)
    self.Button.BackgroundTransparency = 1
    rawset(self, "RegularTransparency", 1)
    for _, item:Instance in self.Button:GetChildren() do
        if item:IsA("UIStroke") and item:GetAttribute("ButtonStyleItem") then
            item:Destroy()
        end
    end
end

return Button