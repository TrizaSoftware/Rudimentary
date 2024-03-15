local Command = {}

-- SETTINGS

Command.Name = "kick"
Command.Aliases = {"removeuser"}
Command.ArgumentsToProcess = {1}
Command.Prefix = "MainPrefix"
Command.Dangerous = true
Command.AdminLevel = 2

-- HANDLER

Command.Handler = function(environment, executingPlayer: Player, targets: {Player}, ...)
    local Reason = table.concat({...}, " ")

    if not Reason:find("%w") then
        Reason = "No reason provided."
    end

    for _, target in targets do
        if typeof(target) == "string" then continue end

        if executingPlayer.AdminLevel > target.AdminLevel then
            target.Player:Kick(Reason)
        end
    end
end

return Command