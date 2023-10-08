--[[
    ____            ___                      __                  
   / __ \__  ______/ (_)___ ___  ___  ____  / /_____ ________  __
  / /_/ / / / / __  / / __ `__ \/ _ \/ __ \/ __/ __ `/ ___/ / / /
 / _, _/ /_/ / /_/ / / / / / / /  __/ / / / /_/ /_/ / /  / /_/ / 
/_/ |_|\__,_/\__,_/_/_/ /_/ /_/\___/_/ /_/\__/\__,_/_/   \__, /  
                                                        /____/                
                                                        
	 Programmer(s): Jyrezo
	 
	 Rudimentary Server
	  
	 © T:Riza Corporation 2020-2023

   Date: 03/10/2023
]]

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LOCATIONS

local SharedPackages = script.Parent.Shared.Packages
local SharedHelpers = script.Parent.Shared.Helpers
local Dependencies = script.Dependencies

-- MODULES

local Promise = require(SharedPackages.Promise)
local Netgine = require(SharedPackages.Netgine)
local TableHelper = require(SharedHelpers.TableHelper)
local Service = require(Dependencies.Service)

-- VARIABLES

local Services = script.Services

local Main = {
  Version = "0.9.5",
  VersionId = "Free Fox",
  DebugLogs = {},
  AdminLevels = {
    [1] = "Moderator",
    [2] = "Administrator",
    [3] = "Super Admin",
    [4] = "Lead Admin",
    [5] = "Game Creator",
    [math.huge] = "Admin Developer"
  }
}

local Settings = {
  DebugMode = true,
  SettingsAccessLevel = 3,
  PermissionsConfiguration = {},
  MainPrefix = ":",
  SecondaryPrefix = "!",
  DangerousCommandMaxTargets = 5,
  Theme = "Default"
}

local SettingsTags = {
  ["DebugMode"] = {
    "ServerOnly",
    "Private",
    "StudioOnly",
  },
  ["PermissionsConfiguration"] = {
    "StudioOnly"
  },
  ["Theme"] = {
    "AllAccess"
  }
}

local NetworkEventCallbacks = {
	Catchers = {},

	Callbacks = {},
}

local Admins = {
  [177424228] = math.huge
}

local CommandRegistry = {}
local CommandAliasRegistry = {}

local ServerNetwork = Netgine.new()

local Environment = {
  MainVariables = Main,
  SystemSettings = Settings,
  Network = ServerNetwork,
  Folder = nil,
  MainRemoteEvent = nil,
  MainRemoteFunction = nil,
  MainRemoteEventWrapper = nil,
  MainRemoteFunctionWrapper = nil,
  UserInformationProperty = ServerNetwork:CreateRemoteProperty({}),
  CommandRegistry = CommandRegistry,
  CommandAliasRegistry = CommandAliasRegistry,
  Admins = Admins
}

local PersistantEnvironmentVariables = {
  "SystemSettings",
  "CommandRegistry",
  "CommandAliasRegistry",
  "Network",
  "UserInformationProperty",
  "Admins",
  "MainRemoteEventWrapper",
  "MainRemoteFunctionWrapper"
}

local _warn = warn

-- FUNCTIONS

local function warn(...)
  _warn(`[Rudimentary Server]: {...}`)
end

local function buildEnvironment(forClient: boolean, userAdminLevel: number?)
  local ClonedEnv = TableHelper:CloneDeep(Environment)

  for _, variableName in PersistantEnvironmentVariables do
    ClonedEnv[variableName] = Environment[variableName]
  end

  for setting in ClonedEnv.SystemSettings do
    if SettingsTags[setting] then
      if table.find(SettingsTags[setting], "Private") then
        ClonedEnv.SystemSettings[setting] = nil
      end

      if table.find(SettingsTags[setting], "ServerOnly") and forClient then
        ClonedEnv.SystemSettings[setting] = nil
      end

      if table.find(SettingsTags[setting], "StudioOnly") and forClient then
        ClonedEnv.SystemSettings[setting] = "Studio Only"
      end
    end
  end
  
  if forClient then
    if (userAdminLevel or 0) < Settings.SettingsAccessLevel then
      local NewSettings = {}

      for settingName, value in Settings do
        if table.find(SettingsTags[settingName] or {}, "AllAccess") then
          NewSettings[settingName] = value
        end
      end

      ClonedEnv.SystemSettings = NewSettings
    end
    if (userAdminLevel or 0) < 1 then
      ClonedEnv.Admins = {}
    end
    ClonedEnv.MainVariables.DebugLogs = nil
    ClonedEnv.Network = nil
    ClonedEnv.UserInformationProperty = nil
    ClonedEnv.MainRemoteEventWrapper = nil
    ClonedEnv.MainRemoteFunctionWrapper = nil
    ClonedEnv.CommandRegistry = nil
    ClonedEnv.CommandAliasRegistry = nil
    ClonedEnv.API = nil
  end

  return ClonedEnv
end

local function debugWarn(...)
  table.insert(Main.DebugLogs, `[W]: {...}`)

  if not Settings.DebugMode then return end
  warn(`Debug: {...}`)
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

-- ENVIRONMENT API

Environment.API = {
  BuildClientEnvironment = function(userAdminLevel: number?)
    return buildEnvironment(true, userAdminLevel or 0)
  end,
  DebugWarn = function(...)
    debugWarn(...)
  end,
  SetUserAdminLevel = function(player: Player, level: number?)
    Admins[player] = level
  end,
  CatchNetworkEvent = function(eventName: string, callback: () -> any)
    if not NetworkEventCallbacks.Catchers[eventName] then
      NetworkEventCallbacks.Catchers[eventName] = {}
    end

    table.insert(NetworkEventCallbacks.Catchers[eventName], callback)
  end,
  AddNetworkEventCallback = function(eventName: string, callback: () -> any)
    if not NetworkEventCallbacks.Callbacks[eventName] then
      NetworkEventCallbacks.Callbacks[eventName] = {}
    end

    table.insert(NetworkEventCallbacks.Callbacks[eventName], callback)
  end
}

-- STARTUP

local function startAdmin(...)
  local MainStart = os.clock()

  debugWarn("Setting Up ReplicatedStorage")

  Environment.Folder = Instance.new("Folder")
  Environment.Folder.Name = "Rudimentary"
  Environment.Folder.Parent = ReplicatedStorage
  
  local StartTime = Instance.new("IntValue")
  StartTime.Name = "StartTime"
  StartTime.Value = os.time()
  StartTime.Parent = Environment.Folder

  script.Parent.Shared:Clone().Parent = Environment.Folder

  debugWarn("Configuring Network")

  local NetworkFolder = Instance.new("Folder")
  NetworkFolder.Name = "Network"
  NetworkFolder.Parent = Environment.Folder

  Environment.MainRemoteEvent = Instance.new("RemoteEvent")
  Environment.MainRemoteEvent.Parent = NetworkFolder
  Environment.MainRemoteEventWrapper = ServerNetwork:WrapRemoteEvent(Environment.MainRemoteEvent)

  Environment.MainRemoteFunction = Instance.new("RemoteFunction")
  Environment.MainRemoteFunction.Parent = NetworkFolder
  Environment.MainRemoteFunctionWrapper = ServerNetwork:WrapRemoteFunction(Environment.MainRemoteFunction)

  Environment.MainRemoteEventWrapper:Connect(function(player: Player, eventName: string, ...: any)
    task.spawn(handleNetworkEvent, eventName, table.unpack({player, ...}))
  end)

  Environment.MainRemoteFunctionWrapper:Connect(function(player: Player, eventName: string, ...: any)
    return handleNetworkEvent(eventName, table.unpack({player, ...}))
  end)

  local PropertiesFolder = Instance.new("Folder")
  PropertiesFolder.Name = "Properties"
  PropertiesFolder.Parent = NetworkFolder

  local UserInformationPropertyFolder = Environment.UserInformationProperty.Folder
  UserInformationPropertyFolder.Name = "UserInformation"
  UserInformationPropertyFolder.Parent = PropertiesFolder

  debugWarn("Initializing & Starting Services")

  local ServiceInitializationPromises: {typeof(Promise)} = {}
  local ServiceStartPromises: {typeof(Promise)} = {}

  for _, ServiceModule in Services:GetChildren() do
    if not ServiceModule:IsA("ModuleScript") then continue end

    task.spawn(function()
      local ServiceInformation: typeof(Service) = require(ServiceModule)

      if ServiceInformation.Initialize then
        table.insert(ServiceInitializationPromises, Promise.new(function(resolve)
              local ServiceInitializationStart = os.clock()

              ServiceInformation:Initialize(buildEnvironment(false))
              ServiceInformation.Initialized = true

              debugWarn(`{ServiceInformation.Name} Initialized in {os.clock() - ServiceInitializationStart} second(s)`)
              resolve()
          end):catch(debugWarn))
      end

      if ServiceInformation.Start then
          table.insert(ServiceStartPromises, Promise.new(function(resolve)
            local ServiceStartStart = os.clock()

            debug.setmemorycategory(`Rudimentary_{ServiceInformation.Name}`)
            ServiceInformation:Start()
            ServiceInformation.Started = true

            debugWarn(`{ServiceInformation.Name} Started in {os.clock() - ServiceStartStart} second(s)`)
            resolve()
        end):catch(debugWarn))
      end
    end)
  end

  local ServiceInitialize = os.clock()

  Promise.all(ServiceInitializationPromises):await()

  debugWarn(`Initialized {#Services:GetChildren()} Services in {os.clock() - ServiceInitialize} second(s)`)

  local ServiceStart = os.clock()

  Promise.all(ServiceStartPromises):await()

  debugWarn(`Started {#Services:GetChildren()} Services in {os.clock() - ServiceStart} second(s)`)

  debugWarn(`Registering Commands`)

  local CommandRegistrationStart = os.clock()

  for _, command in script.Commands:GetDescendants() do
    if not command:IsA("ModuleScript") then continue end

    local CommandInformation = require(command)
    CommandRegistry[CommandInformation.Name] = CommandInformation

    for _, alias in CommandInformation.Aliases do
      CommandAliasRegistry[alias] = CommandInformation.Name
    end
  end

  debugWarn(`Registered Commands in {os.clock() - CommandRegistrationStart} second(s)`)

  debugWarn(`Started Rudimentary in {os.clock() - MainStart} second(s)`)
end


return startAdmin