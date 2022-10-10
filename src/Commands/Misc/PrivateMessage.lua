local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "privatemessage"
Command.Description = "Sends a private message to the specified user."
Command.Aliases = {"pm"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Message", Type = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't send a message to no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local Target = args[1]
	--[[
	if typeof(args[1]) == "table" then
		for _, arg in pairs (args[1]) do
			if typeof(arg) == "Instance" then
				table.insert(Target, arg)
			else
				local user = env.API.findUser(arg)
				if user then
					table.insert(Target, user)
				end
			end
		end
	else
		if typeof(args[1]) == "Instance" then
			table.insert(Target, args[1])
		else
			local user = env.API.findUser(args[1])
			if user then
				table.insert(Target, user)
			end
		end
	end
	]]
	local nt = {}
	if #args >= 2 then
		for i = 2,#args do
			table.insert(nt, args[i])
		end
	end
	local Message = table.concat(nt, " ")
	if Message:len() == 0 then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't send an empty message."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local suc = pcall(function()
		 Message = Chat:FilterStringForBroadcast(Message, plr)
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "Message Filtering Failed."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local UsersSentMessageTo = {}
	for _, user in Target do
		if typeof(user) == "Instance" then
			if user == plr then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't send a message to yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			env.RemoteEvent:FireClient(user, "displayNotification", {
				Type = "Info", 
				Text = "Private Message From:", 
				SecondaryText = plr.Name, 
				ExtraData = {
					InstanceToCreate = "PrivateMessage", 
					InstanceData = {
						Title = string.format("Private Message From: %s", plr.Name),
						Text = Message,
						Sender = plr.Name,
						CanRespond = true
					}
				}
			})
			table.insert(UsersSentMessageTo, user.Name)
		end
	end
	if #UsersSentMessageTo > 0 then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("Successfully sent message to %s", table.concat(UsersSentMessageTo, ", "))})
		env.RemoteEvent:FireClient(plr, "playSound", "Success")
	end
end

return Command