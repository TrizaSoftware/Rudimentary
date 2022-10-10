local TeleportService = game:GetService("TeleportService")
local Command = {}
Command.Name = "rejoin"
Command.Description = "Makes you rejoin the current server."
Command.Aliases = {"rj"}
Command.Prefix = "SecondaryPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 0
Command.Handler = function(env, plr, args)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
end

return Command