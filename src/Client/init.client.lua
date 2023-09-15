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
local TestService = game:GetService("TestService")

-- LOCATIONS

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.Packages
local ClientDependencies = script:WaitForChild("Dependencies")

-- MODULES

local Netgine = require(SharedPackages.Netgine)
local Fader = require(ClientDependencies.Fader)
local Promise = require(SharedPackages.Promise)
local Controller = require(ClientDependencies.Controller)

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

-- CLIENT ENV

local Environment = {}

Environment.API = {

}

-- INITIALIZE AND START CONTROLLERS

local StartTime = os.clock()

warn("Starting Controllers")

local ControllerInitializationPromises: {typeof(Promise)} = {}
local ControllerStartPromises: {typeof(Promise)} = {}

for _, controller in script.Controllers:GetDescendants() do
  if not controller:IsA("ModuleScript") then continue end

  task.spawn(function()
    local ControllerInformation: typeof(Controller) = require(controller)

    if ControllerInformation.Initialize then
      table.insert(ControllerInitializationPromises, Promise.new(function(resolve)
            local ControllerInitializationStart = os.clock()

            ControllerInformation:Initialize(Environment)
            ControllerInformation.Initialized = true

            warn(`{ControllerInformation.Name} Initialized in {os.clock() - ControllerInitializationStart} second(s)`)
            resolve()
        end):catch(warn))
    end

    if ControllerInformation.Start then
        table.insert(ControllerStartPromises, Promise.new(function(resolve)
          local ControllerStartStart = os.clock()

          ControllerInformation:Start()
          ControllerInformation.Started = true

          warn(`{ControllerInformation.Name} Started in {os.clock() - ControllerStartStart} second(s)`)
          resolve()
      end):catch(warn))
    end
  end)
end

-- REPARENT TO PLAYER SCRIPTS

task.defer(function()
  script.Name = "RudimentaryClient"
  script.Parent = Player.PlayerScripts
  warn("Re-parented Script")
end)

warn(`Started Rudimentary in {os.clock() - StartTime} second(s)`)

UserInformationProperty:Observe(function(...)
  print(...)
end)