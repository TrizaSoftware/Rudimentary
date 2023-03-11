local Command = {}
Command.Name = "countdown"
Command.Description = "Puts a countdown on everyone's screen."
Command.Aliases = {"cd"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "Time (In Seconds)", ["Type"] = "Number"}}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a time."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not tonumber(args[1]) then
		args[1] = 10
	else
		args[1] = tonumber(args[1])
	end
	env.RemoteEvent:FireAllClients(
		"MakeCountdown",
		args[1]
	)
end

return Command
