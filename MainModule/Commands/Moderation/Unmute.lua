local Command = {}
Command.Name = "unmute"
Command.Description = "Unmutes the specified user(s)."
Command.Aliases = {"letchat"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't unmute no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			env.RemoteEvent:FireClient(
				target,
				"CanChat",
				true
			)
		end
	end
end

return Command