local Command = {}
Command.Name = "sit"
Command.Description = "Sits the specified user(s)."
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.Aliases = {"forcesit"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 3
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Target = args[1]
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
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't sit no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, tgt in pairs(Target) do
		tgt.Character.Humanoid.Sit = true
	end
	--[[
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("showHint", {Title =  plr.Name, Text = Chat:FilterStringForBroadcast(Message, plr)})
	]]
end

return Command