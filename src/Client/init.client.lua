-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LOCATIONS

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.Packages

-- MODULES

local Netter = require(SharedPackages.Netter)

-- VARIABLES

local ClientNetwork = Netter.new()
local UserInformationProperty = ClientNetwork:RegisterRemoteProperty(Folder.Network.Properties.UserInformation)

UserInformationProperty:Observe(function(...)
  print(...)
end)