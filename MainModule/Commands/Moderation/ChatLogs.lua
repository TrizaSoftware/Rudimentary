local Command = {}
Command.Name = "chatlogs"
Command.Aliases = {"cl"}
Command.Prefix = "MainPrefix"
Command.Description = "See the chatlogs for the server."
Command.Schema = {}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local ChatLogsToSend = {}
	for i,data in env.ChatLogs do
		if i <= 1500 then
			table.insert(ChatLogsToSend, data)
		end
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Chat Logs", Items = ChatLogsToSend, AllowSearch = true, AllowRefresh = true, MethodToCall = "getChatLogs"})
end

return Command