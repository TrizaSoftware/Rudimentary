local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "kick"
Command.Description = "Kicks a user from the server."
Command.Aliases = {"removeuserfromserver"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}

Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to kick."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local Target = args[1]
	--[[
	local Target = {}
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
	local KickReason = "You've been kicked from this server."
	local nt = {}
	if #args >= 2 then
		for i = 2,#args do
			table.insert(nt, args[i])
		end
	end
	KickReason = string.format("%s\nReason: %s",KickReason,if #args >= 2 then table.concat(nt," ") else "No reason provided.")
	KickReason = string.format("%s\nModerator:\n%s",Chat:FilterStringForBroadcast(KickReason, plr),plr.Name)
	if not Target[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to kick."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	else
		if #Target > 5 then
			if env.API.requestAuth(plr, "You're attempting to kick more than 5 people at a time, are you sure you want to contunue?") == false then
				return
			end
		end
		for _, tgt in Target do
			if typeof(tgt) == "Instance" then
				if tgt == plr then
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't kick yourself."})
					continue
				end
				if env.API.getAdminLevel(tgt) < env.API.getAdminLevel(plr) then
					env.API.removePlayerFromServer(tgt, KickReason)
				else
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Permissions Error", Text = string.format("%s has a higher admin level or the same as you", plr.Name)})
					env.RemoteEvent:FireClient(plr, "playSound", "Error")
				end
			end
		end
	end
end

return Command