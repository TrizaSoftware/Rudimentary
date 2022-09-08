--[[

    ______          __         
   / ____/___ _____/ /__  _____
  / /_  / __ `/ __  / _ \/ ___/
 / __/ / /_/ / /_/ /  __/ /    
/_/    \__,_/\__,_/\___/_/     
                               

	 Programmer(s): CodedJimmy
	 
	 Fader
	  
	 © T:Riza Corporation 2020-2022

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedModules = RudimentaryFolder:WaitForChild("Shared")
local Utils = require(SharedModules.Utils)
local Signal = require(SharedModules.Signal)
local TweenService = game:GetService("TweenService")
local _warn = warn
local function warn(...)
	_warn("[Fader]:",...)
end
local Fader = {}
Fader.__index = Fader

function Fader.new(Ui:Frame)
	assert(Ui:IsA("Frame") == true or Ui:IsA("ScrollingFrame") == true, "Ui must be a frame.")
	local self = setmetatable({}, Fader)
	self.Items = {}
	self.FadeOutCompleted = Signal.new()
	self.FadeInCompleted = Signal.new()
	self.Ui = Ui
	self.DesignatedFrame = nil
	for _, item in pairs(self.Ui:GetDescendants()) do
		self:addItemToFader(item)
		if item:IsA("Frame") or item:IsA("ScrollingFrame") then
			for _, item in pairs(item:GetDescendants()) do
				self:addItemToFader(item)
			end
		end 
	end
	Ui.DescendantAdded:Connect(function(item)
		self:addItemToFader(item)
		if item:IsA("Frame") or item:IsA("ScrollingFrame") then
			for _, item in pairs(item:GetDescendants()) do
				self:addItemToFader(item)
			end
		end 
	end)
	Ui.ChildAdded:Connect(function(item)
		self:addItemToFader(item)
		if item:IsA("Frame") or Ui:IsA("ScrollingFrame") then
			for _, item in pairs(item:GetDescendants()) do
				self:addItemToFader(item)
			end
		end 
	end)
	self:addItemToFader(Ui)
	Ui.DescendantRemoving:Connect(function(item)
		self.Items[item] = nil
	end)
	Ui.ChildRemoved:Connect(function(item)
		self.Items[item] = nil
	end)
		
	warn(string.format("Successfully Loaded A Fader Instance For %s.", Ui.Name))
	return self
end

function Fader:addItemToFader(item)
	if not item.Parent then return end
	if Utils.hasProperty(item,"TextTransparency") and item.TextTransparency ~= 1 then
		if not self.Items[item] then
			self.Items[item] = {TextTransparency = item.TextTransparency}
		else
			self.Items[item].TextTransparency = item.TextTransparency
		end
		if self.Ui.Visible == false then
			item.TextTransparency = 1
		end
	end
	if Utils.hasProperty(item,"BackgroundTransparency") and item.BackgroundTransparency ~= 1 then
		if not self.Items[item] then
			self.Items[item] = {BackgroundTransparency = item.BackgroundTransparency}
		else
			self.Items[item].BackgroundTransparency = item.BackgroundTransparency
		end
		if not self.DesignatedFrame then
			self.DesignatedFrame = item
		end
		if self.Ui.Visible == false then
			item.BackgroundTransparency = 1
		end
	end
	if Utils.hasProperty(item,"ImageTransparency") and item.ImageTransparency ~= 1 then
		if not self.Items[item] then
			self.Items[item] = {ImageTransparency = item.ImageTransparency}
		else
			self.Items[item].ImageTransparency = item.ImageTransparency
		end
		if self.Ui.Visible == false then
			item.ImageTransparency = 1
		end
	end
	if Utils.hasProperty(item,"ScrollBarImageTransparency") and item.ScrollBarImageTransparency ~= 1 then
		if not self.Items[item] then
			self.Items[item] = {ScrollBarImageTransparency = item.ScrollBarImageTransparency}
		else
			self.Items[item].ScrollBarImageTransparency = item.ScrollBarImageTransparency
		end
		if self.Ui.Visible == false then
			item.ScrollBarImageTransparency = 1
		end
	end
	if Utils.hasProperty(item,"Transparency") and item.Transparency ~= 1 then
		if not self.Items[item] then
			self.Items[item] = {Transparency = item.Transparency}
		else
			self.Items[item].Transparency = item.Transparency
		end
		if self.Ui.Visible == false then
			item.Transparency = 1
		end
	end
end

function Fader:fadeOut(seconds:number)
	assert(self ~= nil, "This method can only be called in an active Fader Instance.")
	local ClonedTable = Utils.CloneTable(self.Items)
	if not seconds then seconds = 0 end
	for object,properties in pairs(ClonedTable) do
		for property, _ in pairs(properties) do
			ClonedTable[object][property] = 1
		end
		local Tween = TweenService:Create(object, TweenInfo.new(seconds,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), properties)
		Tween:Play()
		if object == self.DesignatedFrame then
			Tween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					self.Ui.Visible = false
					self.FadeOutCompleted:Fire()
				end
			end)
		end
	end
end

function Fader:fadeIn(seconds:number)
	assert(self ~= nil, "This method can only be called in an active Fader Instance.")
	self.Ui.Visible = true
	for object,properties in pairs(self.Items) do
		local Tween = TweenService:Create(object, TweenInfo.new(seconds or 0,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), properties)
		Tween:Play()
		if object == self.DesignatedFrame then
			Tween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					self.FadeInCompleted:Fire()
				end
			end)
		end
	end
end

function Fader:Destroy()
	self = nil
end


return Fader
