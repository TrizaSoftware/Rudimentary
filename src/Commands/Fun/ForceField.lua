local Command = {}
Command.Name = "forcefield"
Command.Description = "Puts a forcefield the user(s)."
Command.Aliases = {"ff"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user to put a force field around."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target.Character:FindFirstChild("RudimentaryForceField") then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s already has a force field.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			local ForceField = Instance.new("ForceField")
			ForceField.Name = "RudimentaryForceField"
			ForceField.Parent = target.Character
		end
	end
end

return Command
