local Command = {}
Command.Name = "noclipfly"
Command.Description = "Noclip flies the specified user(s)."
Command.Aliases = {"ncf"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}}
Command.RequiredAdminLevel = 2
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	task.defer(env.Commands["fly"].Handler,env,plr,{args[1], "true"})
end

return Command