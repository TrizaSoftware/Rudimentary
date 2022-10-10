local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "permanentban"
Command.Description = "Bans a user from the game permanently."
Command.Aliases = {"pban", "permban"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 3
Command.ArgsToReplace = {1}

Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
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

	local BanReason = "You've been banned from this game permanently."
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
			if env.API.requestAuth(plr, "You're attempting to permanently ban more than 5 people at a time, are you sure you want to contunue?") == false then
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
					continue
				end
			end
			if UserId == plr.UserId then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't permanently ban yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			local PermBans = env.DataStore:GetAsync("PermanentBans")
			local Pbanned = false
			for _, bd in PermBans do
				if bd.UserId == UserId then
					Pbanned = true
				end
			end
			if Pbanned then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s is already permanently banned.", Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			if (env.Admins[UserId] or 0) < env.API.getAdminLevel(plr) then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Success", Text = string.format("Successfully permanently banned %s.", Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Success")
				local tgtplr = Players:GetPlayerByUserId(tonumber(UserId))
				if tgtplr then
					env.API.removePlayerFromServer(tgtplr, BanReason)
				end
				table.insert(PermBans, {UserId = UserId, Reason = BanReason})
				env.DataStore:SetAsync("PermanentBans", PermBans)
				env.API.CSM.dispatchMessageToServers({request = "addPermanentBan", userId = UserId, reason = BanReason})
				env.API.addToBanHistory(UserId, 
					string.format("[{time:%s:sdi}] Permanently Banned at {time:%s:ampm} by %s for reason %s", 
						os.time(),
						os.time(),
						plr.Name,
						if #args >= 2 then table.concat(nt," ") else "No reason provided."
					)
				)
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