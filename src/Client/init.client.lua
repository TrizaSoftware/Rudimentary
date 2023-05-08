-- SERVICES

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LOCATIONS

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.Packages

-- MODULES

local Netter = require(SharedPackages.Netter)

-- VARIABLES

local Player = Players.LocalPlayer
local ClientNetwork = Netter.new()
local UserInformationProperty = ClientNetwork:RegisterRemoteProperty(Folder.Network.Properties.UserInformation)

-- REPARENT TO PLAYER SCRIPTS

task.spawn(function()
  script.Name = "RudimentaryClient"
  script.Parent = Player.PlayerScripts
end)



UserInformationProperty:Observe(function(...)
  print(...)
end)