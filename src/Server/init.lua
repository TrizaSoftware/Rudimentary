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

-- MODULES

local Promise = require(script.Parent.Shared.Promise)

-- VARIABLES

local Services = script.Services

local Main = {
  Version = "0.9.5",
  VersionId = "Free Fox"

}

local Configurations = {
  DebugMode = true
}

local _warn = warn

-- FUNCTIONS

local function warn(...)
  _warn(`[Rudimentary Server]: {...}`)
end

local function makeEnvironment(target: ModuleScript)
  
end

local function debugWarn(...)
  if not Configurations.DebugMode then return end

  warn(...)
end

-- STARTUP

local function startAdmin()
  local MainStart = os.clock()

  local ServiceStart = os.clock()

  debugWarn("Initializing & Starting Services")

  local ServiceInitializationPromises = {}

  for _, ServiceModule in Services:GetChildren() do
    if not ServiceModule:IsA("ModuleScript") then continue end

    task.spawn(function()
      local ServiceInformation = require(ServiceModule)

      if ServiceInformation.Initialize then
        table.insert(ServiceInitializationPromises, Promise.new(function(resolve, reject)
              local ServiceInitializationStart = os.clock()

              ServiceInformation:Initialize()

              debugWarn(`{ServiceInformation.Name} Initialized In {os.clock() - ServiceInitializationStart}(s)`)
          end)
        )
      end
    end)
  end

  Promise.all(ServiceInitializationPromises):await():andThen()


end


return startAdmin