local Command = {}
Command.Name = "kill"
Command.Description = "Kills the specified user(s)."
Command.Aliases = {"kll"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't kill no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end

  for _, tgt in args[1] do
    if typeof(tgt) == "Instance" then
      if tgt.Character then
        tgt.Character.Humanoid.Health = 0
        if not env.DisableCommandTargetNotifications then
          env.RemoteEvent:FireClient(tgt, "displayNotification", {
            Type = "Info", 
            Title = "Killed", 
            Text = string.format("You've been killed by %s.", plr.Name)
          })
        end
      end
    end
	end
end

return Command
