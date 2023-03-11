local Command = {}
Command.Name = "unview"
Command.Description = "Makes you look at no one."
Command.Aliases = {"stopwatching"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	env.RemoteEvent:FireClient(
		plr,
		"ViewUser",
		plr
	)
end

return Command