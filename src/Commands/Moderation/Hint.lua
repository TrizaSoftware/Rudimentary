local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "hint"
Command.Description = "Sends a hint to everyone in the server."
Command.Aliases = {"h"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Message", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("showHint", {Title =  plr.Name, Text = Chat:FilterStringForBroadcast(Message, plr)})
end

return Command