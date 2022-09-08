local Command = {}
Command.Name = "removeserverlock"
Command.Description = "Unlocks the server."
Command.Aliases = {"unslock"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "Yes/No", ["Type"] = "String"}}
Command.Handler = function(env, plr, args)
	task.defer(env.Commands.serverlock.Handler,env,plr,{"false"})
end

return Command
