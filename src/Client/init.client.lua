--[[
    ____            ___                      __                  
   / __ \__  ______/ (_)___ ___  ___  ____  / /_____ ________  __
  / /_/ / / / / __  / / __ `__ \/ _ \/ __ \/ __/ __ `/ ___/ / / /
 / _, _/ /_/ / /_/ / / / / / / /  __/ / / / /_/ /_/ / /  / /_/ / 
/_/ |_|\__,_/\__,_/_/_/ /_/ /_/\___/_/ /_/\__/\__,_/_/   \__, /  
                                                        /____/                
                                                        
	 Programmer(s): Jyrezo
	 
	 Rudimentary Client
	  
	 © T:Riza Corporation 2020-2023

   Date: 06/06/2023
]]


-- SERVICES

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestService = game:GetService("TestService")

-- LOCATIONS

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local Shared = Folder.Shared
local Themes = Shared.Themes
local SharedPackages = Shared.Packages
local MaterialIcons = require(Shared.MaterialIcons)
local ClientDependencies = script:WaitForChild("Dependencies")

-- MODULES

local Netgine = require(SharedPackages.Netgine)
local Promise = require(SharedPackages.Promise)
local Controller = require(ClientDependencies.Controller)

-- VARIABLES

local Player = Players.LocalPlayer
local ClientNetwork = Netgine.new()
local MainInterface = script.Parent
local UserInformationProperty = ClientNetwork:RegisterRemoteProperty(Folder.Network.Properties.UserInformation)
local UserInformation = UserInformationProperty:Get()
local _warn = warn
local NetworkEventCallbacks = {
	Catchers = {},

	Callbacks = {},
}

-- FUNCTIONS

function warn(...)
  _warn("[Rudimentary Client]:", ...)
end

local function handleNetworkEvent(networkEvent: string, ...)
  local Data = {...}
  local Responses = {}
  local ResponsePromises = {}

  if NetworkEventCallbacks.Catchers[networkEvent] then
    for _, catacher in NetworkEventCallbacks.Catchers[networkEvent] do
      task.spawn(catacher, table.unpack(Data))
    end
  end

  if NetworkEventCallbacks.Callbacks[networkEvent] then
    for _, callback in NetworkEventCallbacks.Callbacks[networkEvent] do
      table.insert(ResponsePromises, Promise.new(function(resolve)
        table.insert(Responses, callback(table.unpack(Data)))
        resolve()
      end))
    end

    Promise.all(ResponsePromises):await()
  end

  return if Responses[1] and Responses[2] then Responses else Responses[1]
end

-- CLIENT ENV

local Environment = {}

Environment.Interface = MainInterface
Environment.MainRemoteEventWrapper = ClientNetwork:WrapRemoteEvent(Folder.Network.RemoteEvent)
Environment.MainRemoteFunctionWrapper = ClientNetwork:WrapRemoteFunction(Folder.Network.RemoteFunction)
Environment.API = {
  CatchNetworkEvent = function(eventName: string, callback: () -> any)
    if not NetworkEventCallbacks.Catchers[eventName] then
      NetworkEventCallbacks.Catchers[eventName] = {}
    end

    table.insert(NetworkEventCallbacks.Catchers[eventName], callback)
  end,
  GetInterfaceModule = function(interfaceItemName: string)
    return Themes[UserInformation.SystemSettings.Theme]:FindFirstChild(interfaceItemName) or Themes.Default:FindFirstChild(interfaceItemName)
  end
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

    ControllerInformation.Started = false
    ControllerInformation.Initialized = false
  

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

-- PRELOAD ICONS

for _, icon in MaterialIcons do
	task.spawn(function()
		ContentProvider:PreloadAsync({ `rbxassetid://{icon}` })
	end)
end

warn("Preloaded Icons")

warn(`Started Rudimentary in {os.clock() - StartTime} second(s)`)

UserInformationProperty:Observe(function(newInfo)
  UserInformation = newInfo
end)

-- HANDLE REMOTES

Environment.MainRemoteEventWrapper:Connect(function(eventName: string, ...: any)
  task.spawn(handleNetworkEvent, eventName, ...)
end)

Environment.MainRemoteFunctionWrapper:Connect(function(eventName: string, ...: any)
  return handleNetworkEvent(eventName, ...)
end)