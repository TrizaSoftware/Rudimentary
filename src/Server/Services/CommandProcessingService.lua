local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Service = require(Dependencies.Service)
local Promise = require(script.Parent.Parent.Parent.Shared.Packages.Promise)

-- VARIABLES

local Environment

-- SERVICE

local CommandProcessingService = Service.new("CommandProcessingService")

function CommandProcessingService:ProcessCommand(player: Player, ...)
    local Prefix = Environment.MainVariables.Prefix

    local Data = {...}
    local CommandString: string = Data[1]
	local CommandNoPrefix = Prefix:len() >= 1
			and (CommandString:sub(1, Prefix:len()) == Prefix and CommandString:split(Prefix)[2])
		or CommandString
end

function CommandProcessingService:Initialize(Env)
    Environment = Env
    Environment.API.AddNetworkEventCallback("execute", function(player, ...)
        self:ProcessCommand(player, ...)
    end)
end

return CommandProcessingService