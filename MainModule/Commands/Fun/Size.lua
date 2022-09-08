local Command = {}
Command.Name = "size"
Command.Description = "Sizes the user(s) to the specified number."
Command.Aliases = {"sze"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Size", ["Type"] = "Number"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't give a sword to no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a size."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	if not tonumber(args[2]) then
		args[2] = 1
	else
		args[2] = if tonumber(args[2]) > 1000 then 1000 else tonumber(args[2])
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			target.Character.Humanoid.HeadScale.Value *= args[2]
			target.Character.Humanoid.BodyDepthScale.Value *= args[2]
			target.Character.Humanoid.BodyWidthScale.Value *= args[2]
			target.Character.Humanoid.BodyHeightScale.Value *= args[2]
		end
	end
end

return Command
