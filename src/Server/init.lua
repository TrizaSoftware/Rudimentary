--[[
    ____            ___                      __                  
   / __ \__  ______/ (_)___ ___  ___  ____  / /_____ ________  __
  / /_/ / / / / __  / / __ `__ \/ _ \/ __ \/ __/ __ `/ ___/ / / /
 / _, _/ /_/ / /_/ / / / / / / /  __/ / / / /_/ /_/ / /  / /_/ / 
/_/ |_|\__,_/\__,_/_/_/ /_/ /_/\___/_/ /_/\__/\__,_/_/   \__, /  
                                                        /____/                
                                                        
	 Programmer(s): CodedJimmy
	 
	 Rudimentary Server
	  
	 © T:Riza Corporation 2020-2023

   Date: 03/10/2023
]]

-- SERVICES

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LOCATIONS

local SharedPackages = script.Parent.Shared.Packages
local SharedHelpers = script.Parent.Shared.Helpers

-- MODULES

local Promise = require(SharedPackages.Promise)
local Netgine = require(SharedPackages.Netgine)
local TableHelper = require(SharedHelpers.TableHelper)

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
  PermissionsConfiguration = {}
}

local SettingsTags = {
  ["DebugMode"] = {
    "StudioOnly",
    "ServerOnly",
    "Private",
  }
}

local Admins = {
  [177424228] = math.huge
}

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
  Admins = Admins
}

local _warn = warn

-- FUNCTIONS

local function warn(...)
  _warn(`[Rudimentary Server]: {...}`)
end

local function buildEnvironment(forClient: boolean, userAdminLevel: number)
  local ClonedEnv = TableHelper:CloneDeep(Environment)
  ClonedEnv.ServerNetwork = ServerNetwork
  ClonedEnv.UserInformationProperty = Environment.UserInformationProperty

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
    if userAdminLevel or 0 < Settings.SettingsAccessLevel then
      ClonedEnv.SystemSettings = {}
    end
    if userAdminLevel or 0 < 1 then
      ClonedEnv.Admins = {}
    end
    ClonedEnv.MainVariables.DebugLogs = nil
    ClonedEnv.ServerNetwork = nil
    ClonedEnv.UserInformationProperty = nil
    ClonedEnv.MainRemoteEventWrapper = nil
    ClonedEnv.MainRemoteFunctionWrapper = nil
    ClonedEnv.API = nil
  end

  return ClonedEnv
end

local function debugWarn(...)
  table.insert(Main.DebugLogs, `[W]: {...}`)

  if not Settings.DebugMode then return end
  warn(`Debug: {...}`)
end

-- ENVIRONMENT API

Environment.API = {
  BuildClientEnvironment = function()
    return buildEnvironment(true)
  end,
  DebugWarn = function(...)
    debugWarn(...)
  end,
  SetUserAdminLevel = function(player: Player, level: number?)
    Admins[player] = level
  end
}

-- STARTUP

local function startAdmin(...)
  local MainStart = os.clock()

  debugWarn("Setting Up ReplicatedStorage")

  Environment.Folder = Instance.new("Folder")
  Environment.Folder.Name = "Rudimentary"
  Environment.Folder.Parent = ReplicatedStorage

  script.Parent.Shared.Parent = Environment.Folder

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
      local ServiceInformation = require(ServiceModule)

      if ServiceInformation.Initialize then
        table.insert(ServiceInitializationPromises, Promise.new(function(resolve)
              local ServiceInitializationStart = os.clock()

              ServiceInformation:Initialize(buildEnvironment(false))

              debugWarn(`{ServiceInformation.Name} Initialized In {os.clock() - ServiceInitializationStart}(s)`)
              resolve()
          end):catch(debugWarn))
      end

      if ServiceInformation.Start then
          table.insert(ServiceStartPromises, Promise.new(function(resolve)
            local ServiceStartStart = os.clock()

            ServiceInformation:Start()

            debugWarn(`{ServiceInformation.Name} Started In {os.clock() - ServiceStartStart}(s)`)
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

  debugWarn(`Started Rudimentary In {os.clock() - MainStart} second(s)`)
end


return startAdmin