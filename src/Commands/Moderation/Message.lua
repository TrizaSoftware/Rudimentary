local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "message"
Command.Description = "Sends a message to everyone in the server."
Command.Aliases = {"m","msg"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Message", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("displayMessage", {Title = string.format("Message from %s", plr.Name), Text = Chat:FilterStringForBroadcast(Message, plr)})
end

return Command