local Command = {}
Command.Name = "jumpheight"
Command.Description = "Sets the specified user(s) jump height."
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Jump Height", ["Type"] = "Number"}}
Command.Aliases = {"jh"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Target = args[1]
	local Speed = args[2]
	--[[
	if typeof(args[1]) == "table" then
		for _, arg in pairs (args[1]) do
			if typeof(arg) == "Instance" then
				table.insert(Target, arg)
			else
				local user = env.API.findUser(arg)
				if user then
					table.insert(Target, user)
				end
			end
		end
	else
		if typeof(args[1]) == "Instance" then
			Target = args[1]
		else
			Target = env.API.findUser(args[1])
		end
	end
	]]
	if not Target then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't set the jump height of no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not Speed then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify a jump height."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, tgt in pairs(Target) do
		tgt.Character.Humanoid.JumpHeight = tonumber(Speed)
	end
end

return Command