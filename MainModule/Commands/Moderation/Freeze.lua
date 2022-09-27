local Command = {}
Command.Name = "freeze"
Command.Description = "Freezes the specified user(s)."
Command.Aliases = {"fzze"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
  if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't freeze no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end

  for _, target in args[1] do
    if typeof(target) == "Instance" then
      if target.Character then
        target.Character.HumanoidRootPart.Anchored = true
      end
    end
  end
end

return Command
