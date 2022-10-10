local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "gamemessage"
Command.Description = "Sends a message to everyone in the game."
Command.Aliases = {"gm","gmsg"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Message", ["Type"] = "String"}}
Command.RequiredAdminLevel = 4
Command.Handler = function(env, plr, args)
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = "You must specify a message."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	env.API.CSM.dispatchMessageToServers({request = "makeGameMessage", sender = plr.Name, text = Chat:FilterStringForBroadcast(Message, plr)})
end

return Command