local Command = {}
Command.Name = "respawn"
Command.Description = "Respawns the specified user(s)."
Command.Aliases = {"res"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Target = args[1]
	if not Target or #Target < 1 then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't respawn no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, tgt in Target do
		if tgt.Character then
			tgt:LoadCharacter()
			if not env.DisableCommandTargetNotifications then
				env.RemoteEvent:FireClient(tgt, "displayNotification", {
					Type = "Info", 
					Title = "Respawned", 
					Text = string.format("You've been respawned by %s.", plr.Name)
				})
			end
		end
	end
end

return Command
