local Players = game:GetService("Players")
local Command = {}

-- SETTINGS

Command.Name = "kill"
Command.Aliases = {}
Command.ArgumentsToProcess = {1}
Command.Prefix = "MainPrefix"
Command.Dangerous = false
Command.AdminLevel = 2

-- HANDLER

Command.Handler = function(environment, executingPlayer: Player, targets: {})
    for _, target in targets do
        if typeof(target) == "string" then continue end
        
        target.Player.Character.Humanoid:TakeDamage(math.huge)
    end
end

return Command