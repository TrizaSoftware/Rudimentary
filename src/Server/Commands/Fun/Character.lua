local Players = game:GetService("Players")
local Command = {}

-- SETTINGS

Command.Name = "character"
Command.Aliases = {"char"}
Command.ArgumentsToProcess = {1}
Command.Prefix = "MainPrefix"
Command.Dangerous = false
Command.AdminLevel = 2

-- HANDLER

Command.Handler = function(environment, executingPlayer: Player, targets: {}, username: string)
    local UserId

    pcall(function()
        UserId = Players:GetUserIdFromNameAsync(username)
    end)

    if not UserId then return end

    local HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(UserId)

    for _, target in targets do
        if typeof(target) == "string" then continue end

        task.spawn(function()
            target.Player.Character.Humanoid:ApplyDescription(HumanoidDescription)
        end)
    end
end

return Command