local Command = {}
Command.Name = "untrack"
Command.Description = "Stops tracking the specified user(s)."
Command.Aliases = {"stoptracking"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			env.RemoteEvent:FireClient(plr, "StopTracking", target)
		end
	end
end

return Command
