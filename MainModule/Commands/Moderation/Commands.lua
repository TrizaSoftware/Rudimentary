local Command = {}
Command.Name = "commands"
Command.Description = "Gets the commands you have access to."
Command.Aliases = {"cmds"}
Command.Prefix = "MainPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 0
Command.Handler = function(env, plr, args)
	local CommandData = {}
	for _, cmd in pairs(env.Commands) do
		if env.API.getAdminLevel(plr) >= cmd.RequiredAdminLevel then
			table.insert(CommandData, {Data = string.format("%s%s <font face = \"Gotham\">(%s)</font>", 
				if cmd.Prefix == "MainPrefix" then env.Prefix else env.SecondaryPrefix, 
				cmd.Name, 
				cmd.Description
				),ExtraData = string.format("Permission Level: <font face = \"Gotham\">%s+</font>\nAliases: <font face = \"Gotham\">%s</font>", env.AdminLevels[cmd.RequiredAdminLevel], table.concat(cmd.Aliases, ", "))}
			)
		end
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Commands", Items = CommandData, AllowSearch = true, AllowRefresh = true, MethodToCall = "getCommands"})
end

return Command