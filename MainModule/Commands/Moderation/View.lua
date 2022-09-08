local Command = {}
Command.Name = "view"
Command.Description = "Makes you look at the user(s)."
Command.Aliases = {"watch"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't view no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			--[[
			if target == plr then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't view yourself."})
				continue
			end
			]]
			env.RemoteEvent:FireClient(
				plr,
				"ViewUser",
				target
			)
		end
	end
end

return Command