local Command = {}
Command.Name = "removeforcefield"
Command.Description = "Removes a forcefield from the user(s)."
Command.Aliases = {"unff", "rff"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user to remove a force field from."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if not target.Character:FindFirstChild("RudimentaryForceField") then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s doesn't have a force field.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			target.Character.RudimentaryForceField:Destroy()
		end
	end
end

return Command
