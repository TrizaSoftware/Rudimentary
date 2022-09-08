local Command = {}
Command.Name = "ungod"
Command.Description = "Ungods the user(s)."
Command.Aliases = {"ugd"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user to ungod."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			target.Character.Humanoid.MaxHealth = 100
			target.Character.Humanoid.Health = 100
		end
	end
end

return Command
