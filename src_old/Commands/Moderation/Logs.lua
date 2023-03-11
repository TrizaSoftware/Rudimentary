local Players = game:GetService("Players")
local Command = {}
Command.Name = "logs"
Command.Description = "Gets the admin logs."
Command.Aliases = {"l", "adminlogs"}
Command.Prefix = "MainPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local LogsToSend = {}
	for i,data in env.Logs do
		if i <= 1500 then
			table.insert(LogsToSend, {Data = data, Clickable = true})
		end
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Logs", Items = LogsToSend, AllowSearch = true, AllowRefresh = true, MethodToCall = "getLogs"})
end

return Command