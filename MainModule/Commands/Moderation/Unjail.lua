local Command = {}
Command.Name = "unjail"
Command.Description = "Unjails specified user(s)."
Command.Aliases = {"removefromjail"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't unjail no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			local IsInJail = false
			local Jail
			for _, item in env.RWA:GetChildren() do
				if item.Name == "Jail" and item:GetAttribute("UserId") == target.UserId then
					IsInJail = true
					Jail = item
				end
			end
			if not IsInJail then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't in jail.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			Jail:Destroy()
		end
	end
end

return Command
