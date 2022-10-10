local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local SharedModules = RudimentaryFolder:WaitForChild("Shared") :: Folder
local Signal = require(SharedModules.Signal)
local Fader = require(script.Parent.Fader)
local Dropdown = {}
local Properties = {
	["Parent"] = function(self, value)
		assert(typeof(value) == "Instance", "Parent must be an Instance.")
		self.Menu.Parent = value
	end,
	["Position"] = function(self, value)
		assert(typeof(value) == "UDim2", "Position must be a UDim2 value.")
		self.Menu.Position = value
	end,
	["Size"] = function(self, value)
		assert(typeof(value) == "UDim2", "Size must be a UDim2 value.")
		self.Menu.Size = value
	end,
	["Options"] = function(self, value)
		assert(typeof(value) == "table", "Options must be a table.")
		for _, item in self.Menu:GetChildren() do
			if item:IsA("TextButton") then
				item:Destroy()
			end
		end
		for _, option in value do
			local Clone = script.DropdownOption:Clone()
			Clone.Parent = self.Menu
			self.Menu.CanvasSize = UDim2.new(0,0,0,self.Menu.UIListLayout.AbsoluteContentSize.Y+10)
			Clone.Text = option
			Clone.Name = option
			Clone.MouseButton1Click:Connect(function()
				self.OptionSelected:Fire(option)
			end)
		end
	end,
}

Dropdown.__index = Dropdown
Dropdown.__newindex = function(self, index, value)
	if Properties[index] then
		pcall(Properties[index], self, value)
	end
end


function Dropdown.new()
	local self = {}
	self.OptionSelected = Signal.new()
	self.Menu = script.DropdownMenu:Clone()
	self.Fader = Fader.new(self.Menu)
	self.Fader:fadeOut()
	self.Open = false
	return setmetatable(self, Dropdown)
end

function Dropdown:open()
	self.Fader:fadeIn(1)
	self.Open = true
end

function Dropdown:close()
	self.Fader:fadeOut(1)
	self.Open = false
end

function Dropdown:Destroy()
	self.Menu:Destroy()
	self = nil
end

return Dropdown