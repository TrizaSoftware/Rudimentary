local Command = {}
Command.Name = "track"
Command.Description = "Tracks the specified user(s)."
Command.Aliases = {"tck"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to track."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target == plr then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't track yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			env.RemoteEvent:FireClient(plr, "TrackUser", target)
		end
	end
end

return Command
