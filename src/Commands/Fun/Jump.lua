local Command = {}
Command.Name = "jump"
Command.Description = "Makes the specified user(s) jump."
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.Aliases = {"forcejump"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 3
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Target = args[1]
	if not Target then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't make no one jump."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, tgt in pairs(Target) do
		tgt.Character.Humanoid.Jump = true
	end
end

return Command