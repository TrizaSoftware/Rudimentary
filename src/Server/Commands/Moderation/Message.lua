local Chat = game:GetService("Chat")

-- SERVICES

local Command = {}

-- SETTINGS

Command.Name = "message"
Command.Aliases = {"m"}
Command.ArgumentsToProcess = {}
Command.Prefix = "MainPrefix"
Command.Dangerous = true
Command.AdminLevel = 2

-- HANDLER

Command.Handler = function(environment, executingPlayer: Player, ...)
    local Message = table.concat({...}, " ")

    if not Message:find("%w") then
        return
    end

	environment.MainRemoteEventWrapper:FireAll(
		"displayMessage",
		{
			Title = `Message from {executingPlayer.Player.Name == executingPlayer.Player.DisplayName and executingPlayer.Player.Name or `{executingPlayer.Player.DisplayName} (@{executingPlayer.Player.Name})`}`,
			Text = Chat:FilterStringForBroadcast(Message, executingPlayer.Player)
		}
	)
end

return Command