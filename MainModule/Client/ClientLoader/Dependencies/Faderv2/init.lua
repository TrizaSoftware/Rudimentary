--[[

	    ______          __         
	   / ____/___ _____/ /__  _____
	  / /_  / __ `/ __  / _ \/ ___/
	 / __/ / /_/ / /_/ /  __/ /    
	/_/    \__,_/\__,_/\___/_/     
                               

	 Programmer(s): CodedJimmy
	 
	 Fader v2
	  
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

local validFrames = {
	"Frame",
	"ScrollingFrame",
	"ImageLabel"
}
local propertiesToTrack = {
	"BackgroundTransparency",
	"Transparency",
	"TextTransparency",
	"TextStrokeTransparency"
}

function checkValidFrame(frame)
	for _, ft in pairs(validFrames) do
		if frame:IsA(ft) then
			return true
		end
	end
	return false
end

function Fader.new(Frame)
	assert(checkValidFrame(Frame) == true, "Frame Must Be Valid")
	local self = setmetatable({}, Frame)
	
	return self
end

return Fader
