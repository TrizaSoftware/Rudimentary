local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "trelloban"
Command.Description = "Trello bans a user."
Command.Aliases = {"trban"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 3
Command.ArgsToReplace = {1}

Command.Handler = function(env, plr, args)
	if not env.TrelloIntegrations then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "Trello integrations must be enabled to run this command."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to trello ban."})
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
	local BanReason = "You've been trello banned."
	local nt = {}
	if #args >= 2 then
		for i = 2,#args do
			table.insert(nt, args[i])
		end
	end
	BanReason = string.format("%s\nReason: %s",BanReason,if #args >= 2 then table.concat(nt," ") else "No reason provided.")
	BanReason = string.format("%s\nModerator:\n%s",Chat:FilterStringForBroadcast(BanReason, plr),plr.Name)
	if not Target[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	else
		if #Target > 5 then
			if env.API.requestAuth(plr, "You're attempting to ban more than 5 people at a time, are you sure you want to contunue?") == false then
				return
			end
		end
		for _, tgt in Target do
			local UserId = nil
			if typeof(tgt) == "Instance" then
				UserId = tgt.UserId
			elseif tonumber(tgt) ~= nil then
				UserId = tonumber(tgt)
			else
				local suc = pcall(function()
					UserId = Players:GetUserIdFromNameAsync(tgt)
				end)
				if not suc then
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't a valid user.", tgt)})
					env.RemoteEvent:FireClient(plr, "playSound", "Error")
				end
			end
			if UserId == plr.UserId then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't ban yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			if (env.Admins[tonumber(UserId)] or 0) < env.API.getAdminLevel(plr) then
				local tgtplr = Players:GetPlayerByUserId(tonumber(UserId))
				if tgtplr then
					env.API.removePlayerFromServer(tgtplr, BanReason)
				end
				env.API.addUserToBans(tonumber(UserId), {Type = "Trello", Reason = BanReason})
				env.API.makeTrelloRequest("addBan", tonumber(UserId), BanReason)
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Success", Text = string.format("Successfully trello banned %s.", Players:GetNameFromUserIdAsync(UserId))})
				env.API.addToBanHistory(UserId, 
					string.format("[{time:%s:sdi}] Trello Banned at {time:%s:ampm} by %s for reason %s", 
						os.time(),
						os.time(),
						plr.Name,
						if #args >= 2 then table.concat(nt," ") else "No reason provided."
					)
				)
				env.RemoteEvent:FireClient(plr, "playSound", "Success")
			else
				env.RemoteEvent:FireClient(plr,"showHint", {
					Title = "Permissions Error", 
					Text = string.format("%s has a higher admin level or the same as you.", Players:GetNameFromUserIdAsync(UserId))
				})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
	end
end

return Command