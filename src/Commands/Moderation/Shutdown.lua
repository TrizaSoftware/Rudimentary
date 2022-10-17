local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local Command = {}
Command.Name = "shutdown"
Command.Description = "Shuts the current server down."
Command.Aliases = {"sd"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 3
Command.Schema = {{["Name"] = "Reason", ["Type"] = "String"}}
Command.Handler = function(env, plr, args)
	local ShutdownReason = {}
	if #args >= 1 then
		for i = 1,#args do
			table.insert(ShutdownReason, args[i])
		end
	end

	ShutdownReason = if #args >= 1 then table.concat(ShutdownReason, " ") else "No reason provided."

	local suc = pcall(function()
		ShutdownReason = Chat:FilterStringForBroadcast(ShutdownReason, plr)
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Message Filtering Failed."})
		return
	end
	local Approved = env.API.requestAuth(plr, "You're going to shut down this server, are you sure you'd like to continue?")
	if not Approved then
		return
	end
	env.API.enableShutdownMode()
--	env.RemoteEvent:FireAllClients("displayMessage", {Title = "Shutdown", Text = "This server is shutting down.\nJoin a new server."})
	env.RemoteEvent:FireAllClients("showHint", {Title = "Shutdown", Text = "This server is shutting down.", IsSticky = true})
	task.wait(2)
	for _, user in Players:GetPlayers() do
		env.API.removePlayerFromServer(user, string.format("\nServer Shutdown\nReason: %s\nModerator: %s", ShutdownReason, plr.Name))
	end
end

return Command
