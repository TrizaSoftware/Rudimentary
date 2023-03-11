local Command = {}
Command.Name = "sword"
Command.Description = "Gives the specified user(s) a sword."
Command.Aliases = {"swrd"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't give a sword to no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			env.Assets.Sword:Clone().Parent = target.Backpack
		end
	end
end

return Command
