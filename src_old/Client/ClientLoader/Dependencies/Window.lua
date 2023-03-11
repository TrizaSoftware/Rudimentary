local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local SharedModules = RudimentaryFolder:WaitForChild("Shared") :: Folder
local Key = require(SharedModules.Key)
local Fader = require(script.Parent.Fader)
local Dragger = require(script.Parent.Dragger)
local Plr = game.Players.LocalPlayer
local mouse = Plr:GetMouse()
local Window = {}
Window.__index = Window

--[[
local function mouseInFrame(uiobject)
	local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
	local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

	return (y_cond and x_cond)
end
]]

function Window.new(Client,Title,Instances,Size)
	Instances = Instances or {}
	local self = setmetatable({}, Window)
	local Clicked = false
	self.ScreenGui = Instance.new("ScreenGui", Plr.PlayerGui)
	local function bringUIToView()
		self.ScreenGui.DisplayOrder = 101
		for _, item in Plr.PlayerGui:GetChildren() do
			if item:GetAttribute("RudimentaryWindowUI") and item ~= self.ScreenGui then
				item.DisplayOrder = 100
			end
		end
	end
	bringUIToView()
	self.WindowInstance = Client.UI:GetFolderForElement("WindowTemplate").WindowTemplate:Clone()
	self.WindowInstance.Topbar.WindowName.Text = Title
	
	for instance, properties in Instances do
		self:addItem(instance, properties)
	end

	self.ScreenGui.Name = Key(15)
	self.ScreenGui:SetAttribute("RudimentaryWindowUI", true)
	self.ScreenGui.ResetOnSpawn = false

	if Size then
		self.WindowInstance.Size = Size
	end

	self.WindowInstance.Parent = self.ScreenGui
	self.ScreenGui.Parent = Plr.PlayerGui
	self.DraggerInstance = Dragger.new(self.WindowInstance, true)
	self.FaderInstance = Fader.new(self.WindowInstance)
	self.FaderInstance:fadeOut()

	self.WindowInstance.Topbar.close.MouseButton1Click:Connect(function()
		if Clicked then return end
		Clicked = true
		self.FaderInstance:fadeOut(1)
		task.wait(1)
		pcall(function()
			self:Destroy()
		end)
	end)

	task.spawn(function()
		task.wait(0.2)
		self.FaderInstance:fadeIn(1)
	end)

	self.WindowInstance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringUIToView()
		end
	end)

	self.DraggerInstance.Dragging:Connect(function(isDragging)
		if isDragging then
			bringUIToView()
		end
	end)
	--[[
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if mouseInFrame(self.WindowInstance) and self.ScreenGui.DisplayOrder == 101 and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			bringUIToView()
		end
	end)
	]]
	return self
end

function Window:addItem(ItemType:Instance, Properties)
	local Item = Instance.new(ItemType)
	if Properties.Parent == "Window" then
		Properties.Parent = self.WindowInstance
	end
	for property, value in Properties do
		Item[property] = value
	end
	return Item
end

function Window:Destroy()
	self.ScreenGui:Destroy()
	setmetatable(self, nil)
end

return Window
