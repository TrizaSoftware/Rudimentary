local Command = {}
Command.Name = "clientlogs"
Command.Description = "Gets logs for the user(s)."
Command.Aliases = {"cll"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			local LogsToSend = {}
			for i,data in env.ClientLogs[target.UserId] do
				if i <= 1500 then
					table.insert(LogsToSend, {Data = data, Clickable = true})
				end
			end
			env.RemoteEvent:FireClient(plr, "makeList", {
				Title = string.format("Client Logs for %s", target.Name), 
				Items = LogsToSend, 
				AllowSearch = true, 
				AllowRefresh = true,
				MethodToCall = "getClientLogs",
				ReqArgs = {plr.UserId}
			})
		end
	end
end

return Command