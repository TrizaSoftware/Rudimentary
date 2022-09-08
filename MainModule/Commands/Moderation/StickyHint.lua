local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "stickyhint"
Command.Description = "Sends a sticky hint to everyone in the server."
Command.Aliases = {"sh"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Message", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("showHint", {Title = string.format("Sticky Hint from %s", plr.Name), Text = Chat:FilterStringForBroadcast(Message, plr), Sticky = true})
end

return Command