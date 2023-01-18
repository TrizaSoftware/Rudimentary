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
local Signal = require(SharedModules.BetterSignal)
local TweenService = game:GetService("TweenService")
local _warn = warn
local function warn(...)
	_warn("[Fader]:",...)
end
local Fader = {}
Fader.__index = Fader


function Fader.new(Ui:Frame)
	assert(Ui:IsA("Frame") == true or Ui:IsA("ScrollingFrame"), "Ui must be a frame.")
	local self = setmetatable({}, Fader)
	self.Items = {}
	self.FadeOutCompleted = Signal.new()
	self.FadeInCompleted = Signal.new()
	self.Ui = Ui
	self.DesignatedFrame = nil
	for _, item in pairs(self.Ui:GetDescendants()) do
		self:addItemToFader(item)
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
	return self
end

function Fader:addItemToFader(item)
	if Utils.hasProperty(item,"TextTransparency") then
		if not self.Items[item] then
			self.Items[item] = {TextTransparency = item.TextTransparency}
		else
			self.Items[item].TextTransparency = item.TextTransparency
		end
	end
	if Utils.hasProperty(item,"BackgroundTransparency") then
		if not self.Items[item] then
			self.Items[item] = {BackgroundTransparency = item.BackgroundTransparency}
		else
			self.Items[item].BackgroundTransparency = item.BackgroundTransparency
		end
	end
	if Utils.hasProperty(item,"ImageTransparency") then
		if not self.Items[item] then
			self.Items[item] = {ImageTransparency = item.ImageTransparency}
		else
			self.Items[item].ImageTransparency = item.ImageTransparency
		end
	end
	if Utils.hasProperty(item,"ScrollBarImageTransparency") then
		if not self.Items[item] then
			self.Items[item] = {ScrollBarImageTransparency = item.ScrollBarImageTransparency}
		else
			self.Items[item].ScrollBarImageTransparency = item.ScrollBarImageTransparency
		end
	end
	if Utils.hasProperty(item, "Transparency") and item:IsA("UIStroke") then
		if not self.Items[item] then
			self.Items[item] = {Transparency = item.Transparency}
		else
			self.Items[item].Transparency = item.Transparency
		end
	end
end

function Fader:fadeOut(seconds:number)
	assert(self ~= nil, "This method can only be called in an active Fader Instance.")
	local ClonedTable = Utils.CloneTableDeep(self.Items)
	seconds = seconds or 0
	for object,properties in pairs(ClonedTable) do
		for property, _ in pairs(properties) do
			ClonedTable[object][property] = 1
		end
		local Tween = TweenService:Create(object, TweenInfo.new(seconds,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), properties)
		Tween:Play()
		if object == self.Ui then
			Tween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed then
					self.FadeOutCompleted:Fire()
				end
			end)
		end
	end
	task.spawn(function()
		task.wait(seconds)
		if self.Ui.BackgroundTransparency == 1 then
			self.Ui.Visible = false
		end
	end)
end

function Fader:fadeIn(seconds:number)
	assert(self ~= nil, "This method can only be called in an active Fader Instance.")
	self.Ui.Visible = true
	for object,properties in pairs(self.Items) do
		local Tween = TweenService:Create(object, TweenInfo.new(seconds or 0,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), properties)
		Tween:Play()
		if object == self.Ui then
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