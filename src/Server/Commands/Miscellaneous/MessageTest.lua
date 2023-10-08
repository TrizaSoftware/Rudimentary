local Command = {}

-- SETTINGS

Command.Name = "messagetest"
Command.Aliases = {"mt"}
Command.ArgumentsToProcess = {1}
Command.Prefix = "SecondaryPrefix"
Command.Dangerous = false
Command.AdminLevel = 2

-- HANDLER

Command.Handler = function(environment, executingPlayer: Player, targets: {Player}, ...)
    environment.MainRemoteEventWrapper:Fire(executingPlayer.Player, "displayMessage", {Title = "This is a Test Message", Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur faucibus elit aliquet nibh dapibus blandit. Aliquam dapibus sollicitudin pretium. Quisque."})
end

return Command