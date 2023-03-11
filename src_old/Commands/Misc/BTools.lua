local Command = {}
Command.Name = "buildingtools"
Command.Description = "Gives the specified user(s) building tools."
Command.Aliases = {"btools"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 3
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't give building tools to no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			env.Assets["Building Tools"]:Clone().Parent = target.Backpack
		end
	end
end

return Command
