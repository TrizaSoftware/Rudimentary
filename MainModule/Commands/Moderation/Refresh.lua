local Command = {}
Command.Name = "refresh"
Command.Description = "Refreshes the specified user(s)."
Command.Aliases = {"ref"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Target = args[1]
	if not Target or #Target < 1 then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't refresh no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, tgt in Target do
		if tgt.Character then
			local OldCFrame = tgt.Character.HumanoidRootPart.CFrame
			tgt:LoadCharacter()
			tgt.Character.HumanoidRootPart.CFrame = OldCFrame
			if not env.DisableCommandTargetNotifications then
				env.RemoteEvent:FireClient(tgt, "displayNotification", {
					Type = "Info", 
					Title = "Refreshed", 
					Text = string.format("You've been refreshed by %s.", plr.Name)
				})
			end
		end
	end
end

return Command
