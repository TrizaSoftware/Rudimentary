local Command = {}
Command.Name = "to"
Command.Description = "Teleports you to the specified user."
Command.Aliases = {"tpmeto"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	task.defer(env.Commands["teleport"].Handler,env,plr,{{plr}, {args[1][1]}})
end

return Command