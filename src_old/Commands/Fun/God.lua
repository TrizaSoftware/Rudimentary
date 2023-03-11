local Command = {}
Command.Name = "god"
Command.Description = "Gods the user(s)."
Command.Aliases = {"gd"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user to god."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			target.Character.Humanoid.MaxHealth = math.huge
			target.Character.Humanoid.Health = math.huge
		end
	end
end

return Command
