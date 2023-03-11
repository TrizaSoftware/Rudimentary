local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "servermessage"
Command.Description = "Sends a message to everyone in the server as the server."
Command.Aliases = {"sm","smsg"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Message", ["Type"] = "String"}}
Command.RequiredAdminLevel = 3
Command.Handler = function(env, plr, args)
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("displayMessage", {Title = env.ServerMessageTitle or "Server Message", Text = Chat:FilterStringForBroadcast(Message, plr)})
end

return Command