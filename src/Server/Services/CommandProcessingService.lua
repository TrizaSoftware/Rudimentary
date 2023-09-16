local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Service = require(Dependencies.Service)
local Promise = require(script.Parent.Parent.Parent.Shared.Packages.Promise)

-- VARIABLES

local Environment

-- SERVICE

local CommandProcessingService = Service.new("CommandProcessingService")

function CommandProcessingService:ProcessCommand()
    
end

function CommandProcessingService:Initialize(Env)
    Environment = Env

    Environment.API.AddNetworkEventCallback("execute", function(player, ...)
        self:ProcessCommand(player, ...)
    end)
end

return CommandProcessingService