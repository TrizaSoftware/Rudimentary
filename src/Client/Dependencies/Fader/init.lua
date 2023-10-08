--[[

    ______          __         
   / ____/___ _____/ /__  _____
  / /_  / __ `/ __  / _ \/ ___/
 / __/ / /_/ / /_/ /  __/ /    
/_/    \__,_/\__,_/\___/_/     
                               

	 Programmer(s): CodedJimmy
	 
	 Fader v2.0
	  
	 © T:Riza Corporation 2020-2023

]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Dependencies = script:WaitForChild("Dependencies")
local Signal = require(Dependencies:WaitForChild("BetterSignal"))
local FaderInstances = {}
local ValidFrames = {
	"Frame",
	"ImageLabel",
	"ScrollingFrame",
}
local ValidProperties = {
	"BackgroundTransparency",
	"TextTransparency",
	"ScrollBarImageTransparency",
	"TextStrokeTransparency",
	"ImageTransparency",
}
local SpecialPropertiesForItems = {
	["UIStroke"] = {
		"Transparency",
	},
}
local InstancesToNotCheck = {
	"UIGradient",
	"UIListLayout",
	"UIGridLayout",
}

function hasProperty(item: Instance, property: string)
	local suc = pcall(function()
		local test = item[property]
	end)
	return suc
end

function checkIsInFader(item: Instance)
	for _, faderInstance in FaderInstances do
		if faderInstance.InterfaceItems[item] then
			return true
		end
	end
	return false
end

function pickItem(itemTable: table)
	for item, properties in itemTable do
		for property, value in properties do
			if value ~= 1 then
				return item
			end
		end
	end
	return nil
end

function CloneTable(table)
	local ClonedTable = {}
	for i, v in pairs(table) do
		if typeof(v) == "table" then
			ClonedTable[i] = CloneTable(v)
		else
			ClonedTable[i] = v
		end
	end
	return ClonedTable
end

local Fader = {}
Fader.__index = Fader

function Fader.new(interface: Instance)
	local self = setmetatable({}, Fader)
	assert(
		table.find(ValidFrames, interface.ClassName) ~= nil,
		string.format("%s isn't a valid FrameType.", interface.ClassName)
	)
	self.MainInterface = interface
	self.InterfaceItems = {}
	self.EasingStyle = "Quint"
	self.FadedOut = Signal.new()
	self.FadedIn = Signal.new()
	self.FadeStatus = "FadedIn"
	self.Fading = false
	self:addItem(interface)
	for _, item: Instance in interface:GetDescendants() do
		if not checkIsInFader(item) then
			self:addItem(item)
		end
	end
	interface.DescendantAdded:Connect(function(item)
		if not checkIsInFader(item) then
			self:addItem(item)
		end
	end)
	interface.DescendantRemoving:Connect(function(item)
		if self.InterfaceItems[item] then
			self.InterfaceItems[item] = nil
		end
	end)
	table.insert(FaderInstances, self)
	return self
end

function Fader:setEasingStyle(style: string)
	local foundStyle = false
	for _, item in Enum.EasingStyle:GetEnumItems() do
		if item.Name == style then
			foundStyle = true
			self.EasingStyle = style
		end
	end
	if not foundStyle then
		error(string.format("%s isn't a valid EasingStyle.", style))
	end
end

function Fader:addItem(item: Instance)
	if not table.find(InstancesToNotCheck, item.ClassName) then
		self.InterfaceItems[item] = {}
		for _, property in ValidProperties do
			if hasProperty(item, property) then
				self.InterfaceItems[item][property] = item[property]
			end
		end
		if SpecialPropertiesForItems[item.ClassName] then
			for _, property in SpecialPropertiesForItems[item.ClassName] do
				self.InterfaceItems[item][property] = item[property]
			end
		end
		if (self.FadeStatus == "FadedOut" and not self.Fading) or (self.FadeStatus == "FadedIn" and self.Fading) then
			for property, _ in self.InterfaceItems[item] do
				item[property] = 1
			end
		end
	end
end

function Fader:fadeOut(seconds: number)
	seconds = seconds or 0
	local Item = pickItem(self.InterfaceItems)
	assert(Item, "At least one item must contain a property which can be tracked.")
	self.Fading = true
	self.FadeStatus = "FadingOut"
	local ClonedItems = CloneTable(self.InterfaceItems)
	for item, properties in ClonedItems do
		for property, _ in properties do
			ClonedItems[item][property] = 1
		end
	end
	for item, properties in ClonedItems do
		local Tween = TweenService:Create(item, TweenInfo.new(seconds, Enum.EasingStyle[self.EasingStyle]), properties)
		Tween:Play()
		if Item == item then
			Tween.Completed:Connect(function(playbackState)
				if playbackState == Enum.PlaybackState.Completed and self.FadeStatus ~= "FadingIn" then
					self.FadeStatus = "FadedOut"
					self.Fading = false
					self.FadedOut:Fire()
					self.MainInterface.Visible = false
				end
			end)
		end
	end
end

function Fader:fadeIn(seconds: number)
	seconds = seconds or 0
	local Item = pickItem(self.InterfaceItems)
	assert(Item, "At least one item must contain a property which can be tracked.")
	RunService.Heartbeat:Wait()
	self.MainInterface.Visible = true
	self.Fading = true
	self.FadeStatus = "FadingIn"
	for item, properties in self.InterfaceItems do
		local Tween = TweenService:Create(item, TweenInfo.new(seconds, Enum.EasingStyle[self.EasingStyle]), properties)
		Tween:Play()
		if Item == item then
			Tween.Completed:Connect(function(playbackState)
				if playbackState == Enum.PlaybackState.Completed then
					self.FadeStatus = "FadedIn"
					self.Fading = false
					self.FadedIn:Fire()
				end
			end)
		end
	end
end

return Fader
