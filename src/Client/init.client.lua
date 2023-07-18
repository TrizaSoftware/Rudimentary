--[[
    ____            ___                      __                  
   / __ \__  ______/ (_)___ ___  ___  ____  / /_____ ________  __
  / /_/ / / / / __  / / __ `__ \/ _ \/ __ \/ __/ __ `/ ___/ / / /
 / _, _/ /_/ / /_/ / / / / / / /  __/ / / / /_/ /_/ / /  / /_/ / 
/_/ |_|\__,_/\__,_/_/_/ /_/ /_/\___/_/ /_/\__/\__,_/_/   \__, /  
                                                        /____/                
                                                        
	 Programmer(s): CodedJimmy
	 
	 Rudimentary Client
	  
	 © T:Riza Corporation 2020-2023

   Date: 06/06/2023
]]


-- SERVICES

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LOCATIONS

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.Packages
local ClientDependencies = script:WaitForChild("Dependencies")

-- MODULES

local Netgine = require(SharedPackages.Netgine)
local Fader = require(ClientDependencies.Fader)

-- VARIABLES

local Player = Players.LocalPlayer
local ClientNetwork = Netgine.new()
local MainInterface = script.Parent
local UserInformationProperty = ClientNetwork:RegisterRemoteProperty(Folder.Network.Properties.UserInformation)
local UserInformation = UserInformationProperty:Get()
local _warn = warn

-- FUNCTIONS

function warn(...)
  _warn("[Rudimentary Client]:", ...)
end

-- REPARENT TO PLAYER SCRIPTS

task.defer(function()
  script.Name = "RudimentaryClient"
  script.Parent = Player.PlayerScripts
  warn("Re-parented Script")
end)


UserInformationProperty:Observe(function(...)
  print(...)
end)